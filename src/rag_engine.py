from dotenv import load_dotenv
import os
import streamlit as st

from langchain_community.embeddings import HuggingFaceEmbeddings
from langchain_community.vectorstores import FAISS
from langchain_groq import ChatGroq

# ----------------------------------
# Load environment variables
# ----------------------------------
load_dotenv()
GROQ_API_KEY = os.getenv("GROQ_API_KEY")

# ----------------------------------
# BASE PATH 
# ----------------------------------
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
FAISS_PATH = os.path.join(BASE_DIR, "data", "faiss_index")

# ----------------------------------
# Load embeddings 
# ----------------------------------
@st.cache_resource(show_spinner=False)
def load_embeddings():
    return HuggingFaceEmbeddings(
        model_name="sentence-transformers/all-MiniLM-L6-v2"
    )

# ----------------------------------
# Load FAISS vectorstore 
# ----------------------------------
@st.cache_resource(show_spinner=False)
def load_vectorstore():
    embeddings = load_embeddings()
    return FAISS.load_local(
        FAISS_PATH,
        embeddings,
        allow_dangerous_deserialization=True
    )

# ----------------------------------
# Load Groq LLM 
# ----------------------------------
@st.cache_resource(show_spinner=False)
def load_llm():
    return ChatGroq(
        api_key=GROQ_API_KEY,
        model="llama-3.1-8b-instant",
        temperature=0.2
    )

# ----------------------------------
# Core RAG function 
# ----------------------------------
def ask_business_question(question: str, top_k: int = 8) -> str:
    vectorstore = load_vectorstore()
    llm = load_llm()

    docs = vectorstore.similarity_search(question, k=top_k)

    context = "\n".join([
        f"[Category: {doc.metadata.get('category')} | "
        f"Area: {doc.metadata.get('area')}] "
        f"{doc.page_content}"
        for doc in docs
    ])

    prompt = f"""
You are a senior business analyst at Blinkit.

Customer feedback excerpts:
{context}

Question:
{question}

Instructions:
- Identify ONE clear root cause
- Be specific about PRODUCT and LOCATION
- Do NOT give generic reasons
- Answer in ONE sentence only
- Follow this format strictly:

"Customers are reporting that <product> in the <area> are facing <issue> due to <cause>."
"""

    return llm.invoke(prompt).content
