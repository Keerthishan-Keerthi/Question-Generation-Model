#model with position passing
import spacy
from fuzzywuzzy import process
import mysql.connector
import openai
from fpdf import FPDF
from fpdf.enums import XPos, YPos
from io import BytesIO
import re

#!!!SkillsMatcher!!!
# Load SpaCy model
nlp = spacy.load("en_core_web_sm")

#fetching job description
def fetch_advertisement(job):
    try:
        conn = mysql.connector.connect(
            host='localhost',
            user='root',
            password='',
            database='interviewsupportsystem'
        )
        cursor = conn.cursor()
        cursor.execute("""
            SELECT A_Description 
            FROM advertisement
            WHERE Job_Title = %s
        """, (job,))
        
        result = cursor.fetchone()
        if result:
            a_description = result[0]
            # Remove HTML tags
            clean_description = re.sub(r'<[^>]*>', '', a_description)
            return clean_description
        else:
            print("No advertisement found for the given job title.")
            return None

    except mysql.connector.Error as err:
        print(f"Error loading advertisement: {err}")
        return None
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()
            
    
def extract_and_match_skills(job_description, skills_list, threshold=80):
    
    # Process job description with SpaCy
    doc = nlp(job_description)

    # Extract skills as noun phrases and named entities
    extracted_skills = set()
    for chunk in doc.noun_chunks:
        lemma_chunk = " ".join([token.lemma_ for token in chunk])
        if len(lemma_chunk) > 1:  # Filter out single letters
            extracted_skills.add(lemma_chunk.lower().strip())

    for entity in doc.ents:
        lemma_entity = " ".join([token.lemma_ for token in entity])
        if len(lemma_entity) > 1:  # Filter out single letters
            extracted_skills.add(lemma_entity.lower().strip())

    # Perform fuzzy matching
    matches = []
    for skill in skills_list:
        match, score = process.extractOne(skill, extracted_skills)
        if score >= threshold:
            matches.append(skill)
    
    return matches
    
#!!!QuestionsGenerator!!!

# Set up OpenAI API key directly
openai.api_key = ''  

# Function to create a prompt for generating interview questions
def create_prompt(skills):
    prompt = "I need you to generate personalized and detailed interview questions tailored to any of the five skills listed below.\n"
    prompt += "These questions should be professional, relevant and framed in a way that a hiring manager would realistically ask during an interview.\n"
    prompt += "Please follow the following guidelines while generating the questions:\n"
    prompt += "1. Focus on assessing the candidate's practical experience, critical thinking, or problem-solving abilities related to each skill.\n"
    prompt += "2. Avoid generic or overly broad questions; aim for specificity.\n"
    prompt += "3. Create one thought-provoking question for each skill, designed to elicit insights into the candidate's expertise.\n"
    prompt += "Here are the skills to focus on\n:"
    for skill in skills:
        prompt += f"- {skill}\n"
    prompt += "Use a professional tone, and ensure the questions are tailored to showcase the unique demands of each skill in the workplace. no need for explanations"
    return prompt

# Generate interview questions using OpenAI
def generate_questions(candidate_skills):
    if not candidate_skills:
        return[]

    try: 
        # Create the prompt
        prompt = create_prompt(candidate_skills)
        
        # Generate questions using the OpenAI API
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",  
            messages=[
                {"role": "system", "content": "You are a helpful assistant."},
                {"role": "user", "content": prompt}
            ],
            max_tokens=200,  # Adjust as needed to ensure the questions are complete
            n=1,
            temperature=0.7,
        )
        
        # Extract and print the generated questions
        generated_text = response.choices[0].message['content'].strip()
        generated_questions = generated_text.split('\n')
        return generated_questions

    except Exception as e:
        print(f"Error generating questions: {e}")
        return []  # Return an empty list if there is an error

#!!!PDF Creator!!!
# Custom PDF class with header and footer
class CustomPDF(FPDF):
    def header(self):
        self.set_font("helvetica", "B", 14)
        self.cell(0, 10, "SMARTRECRUITER - X DOCUMENT", new_x=XPos.LMARGIN, new_y=YPos.NEXT, align='C')
        self.set_text_color(0, 0, 255)
        self.set_draw_color(0, 0, 128)
        self.set_line_width(0.5)
        self.line(10, 20, 200, 20)  
        self.ln(10)

    def footer(self):
        self.set_y(-15)
        self.set_font("helvetica", "I", 10)
        self.set_text_color(128)
        page_number_text = f"Page {self.page_no()} of {{nb}}"
        self.cell(0, 10, page_number_text, align="C")

# Function to create PDF in memory
def create_pdf(name, GeneratedQuestions):
    pdf = CustomPDF()
    pdf.alias_nb_pages()
    pdf.add_page()

    # Add the main heading with a larger font size
    pdf.set_font("helvetica", "B", size=36)  # Bold, size 36
    pdf.set_text_color(0, 0, 255)
    pdf.cell(200, 10, text="Recommended Questions", new_x=XPos.LMARGIN, new_y=YPos.NEXT, align='C')
    pdf.ln(5)  # Space after heading

    # Reset text color if needed for other parts
    pdf.set_text_color(0, 0, 0)  # Back to black for other text
    
    # Add a subheading with a slightly smaller font size
    pdf.set_font("helvetica", "I", size=20)  # Italic, size 20
    pdf.cell(200, 10, text=f"Candidate Name: {name}", new_x=XPos.LMARGIN, new_y=YPos.NEXT, align='C')
    pdf.ln(10)  # Space after subheading

    # Add questions
    pdf.set_font("helvetica", size=14)
    cell_width = 190
    line_height = 6

    for line in GeneratedQuestions:
        pdf.multi_cell(cell_width, line_height, text=line)
        pdf.ln(3)

    # Save PDF to a BytesIO object (in-memory buffer)
    pdf_buffer = BytesIO()
    pdf.output(pdf_buffer)
    pdf_buffer.seek(0)  # Go back to the beginning of the buffer
    return pdf_buffer.getvalue()



# Function to save PDF and generated questions to the database
def save_to_db(pdf_data, questions, email):
    try:
        conn = mysql.connector.connect(
            host='localhost',
            user='root',
            password='',
            database='interviewsupportsystem'
        )
        cursor = conn.cursor()
        cursor.execute("""
            UPDATE resumes SET Questions = %s WHERE C_Email = %s
        """, (pdf_data, email))
        conn.commit()
        print(f"PDF and questions for {email} saved successfully to database.")

    except mysql.connector.Error as err:
        print(f"Error: {err}")
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

# Main function to fetch each candidate's skills, generate questions, and save to database
def process_candidates(job_pos):
    try:
        conn = mysql.connector.connect(
            host='localhost',
            user='root',
            password='',
            database='interviewsupportsystem'
        )
        cursor = conn.cursor()
        cursor.execute("""
            SELECT user.First_Name, user.Last_Name, resumes.C_Email, resumes.Technical_Skills_Language, resumes.Technical_Skills_Tools, resumes.SoftSkills_Communication, resumes.SoftSkills_Leadership
            FROM resumes
            JOIN user ON resumes.C_Email = user.Email
            WHERE resumes.Job_Title = %s
        """,(job_pos, ))
        rows = cursor.fetchall()
        
       # job_Pos = job
        job_description = fetch_advertisement(job_pos)
        
        for row in rows:
            First_Name, Last_Name, C_Email, Technical_Skills_Language, Technical_Skills_Tools, SoftSkills_Communication, SoftSkills_Leadership = row
            
            full_name = f"{First_Name} {Last_Name}"
            all_skills = f"{Technical_Skills_Language}, {Technical_Skills_Tools}, {SoftSkills_Communication}, {SoftSkills_Leadership}"
            new_skills_list = [skill.strip() for skill in all_skills.split(",")]
            
            matched_skills = extract_and_match_skills(job_description, new_skills_list, threshold=80)
            generated_questions = generate_questions(matched_skills)
            if generated_questions:
                pdf_data = create_pdf(full_name, generated_questions)
                save_to_db(pdf_data, generated_questions, C_Email)
            else:
                print(f"No questions generated for {full_name}.")

    except mysql.connector.Error as err:
        print(f"Error: {err}")
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

# Run the process
Job_pos = "Intern Machine Learning Engineerr"
process_candidates(Job_pos)
