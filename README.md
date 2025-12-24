# Blinkit Business Decision Platform

A production-ready analytics and AI platform for quick-commerce businesses that combines dashboards, machine learning, and GenAI to support data-driven decision-making.

---

## Overview

This project extends traditional dashboards by:
- Analyzing business performance
- Predicting delivery delay risk before dispatch
- Explaining customer issues using GenAI on feedback data

---

## Architecture

- **Data Engineering:** PostgreSQL views for analytics, orders, and feedback  
- **Analytics:** Streamlit dashboard with KPIs and trends  
- **Machine Learning:** XGBoost model for delivery delay prediction  
- **GenAI (RAG):** FAISS + Groq LLM for customer feedback insights  

---

## Features

- Interactive analytics dashboard
- Delivery risk calculator (Low / Medium / High)
- AI assistant for business “why” questions

---

## Tech Stack

- PostgreSQL  
- Pandas, SQLAlchemy  
- Scikit-learn, XGBoost  
- Streamlit  
- LangChain, FAISS, Groq  
- Sentence-Transformers  

---

## Setup
- pip install -r requirements.txt
- streamlit run src/app.py

---

## Environment Variables
### Create a `.env` file:
```
DB_HOST=localhost
DB_PORT=5432
DB_NAME=blinkit_db
DB_USER=postgres
DB_PASSWORD=your_password
GROQ_API_KEY=your_groq_api_key
```
---

## Model Selection 

Multiple classification models were evaluated using ROC-AUC:

| Model               | AUC Score |
|---------------------|-----------|
| Logistic Regression | 0.968     |
| XGBoost             | 0.956     |
| Random Forest       | 0.952     |
| KNN                 | 0.925     |

---

## Why XGBoost was selected:
- Captures non-linear interactions between time, area, and delivery behavior
- More robust for operational and logistics data
- Industry standard for tabular machine learning problems
- Slightly lower AUC but stronger real-world generalization

---

## Model Summary
- **Problem:** Delivery delay prediction (binary classification)
- **Final Model:** XGBoost
- **Reason:** Robust, non-linear, production-suitable for logistics data

---

## GenAI Design
- Feedback embedded and stored in FAISS
- Relevant feedback retrieved per query
- LLM generates concise, business-focused answers

---

## Manju R
