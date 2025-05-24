# Question-Generation-Model

The Personalized question generation model is designed in a way to have two major components, namely Skills matcher and Questions generator.
Skills matcher is responsible for extracting the required skills for the specific job from the skills mentioned by the candidate in their resume. For this purpose, the job advertisement and skills found in the candidate CV will be used as inputs and the output is mentioned as “Matching Skills” throughout the document.
Next component is the questions generator which is crucial for the process of generating personalized interview questions. This component will use a prompt and the output of the above model and utilizes Open AI’s GPT 3.5-turbo model to generate personalized interview questions. Then the output will be extracted and will be rendered in a format which is suitable to be used during startup interviews.
The following diagram will assist you to understand the model architecture in a glance.
 



![image](https://github.com/user-attachments/assets/4eb71ec2-f4db-4bf3-b7dc-08779ba35364)



Note: This is not an independent model. This is a part of a project called SmartRecruiter-X. This model needs inputs from various other models of the above mentioned project.

Database which is need for the functioning of this model is also included.
