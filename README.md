# Sistem Informasi Keuangan

Welcome to the **Sistem Informasi Keuangan** (Financial Information System) repository. This project is structured to house both the frontend application and the backend API services in a clear, organized manner.

## Repository Structure

The project code is divided into two primary sub-directories:

- **[`/backend`](./backend)**: The RESTful API service built with **NestJS**, **TypeORM**, and **PostgreSQL**.
- **[`/frontend`](./frontend)**: The user interface client built with **React**, **Vite**, and **TypeScript**.

## Getting Started

To get a local copy up and running, follow these steps.

### Prerequisites

- Node.js (v18+ recommended)
- PostgreSQL (for the backend database)

### Initial Setup

1. **Clone the repository**
   ```bash
   git clone <your-repository-url>
   cd keuangan
   ```

2. **Start the Backend**
   Navigate to the backend directory, install the required dependencies, and configure the environment variables.
   ```bash
   cd backend
   npm install
   cp .env.example .env
   # Update your .env file with valid PostgreSQL credentials
   npm run start:dev
   ```
   > *For more detailed instructions, please refer to the [Backend README](./backend/README.md).*

3. **Start the Frontend**
   In a new terminal window, navigate to the frontend directory, install dependencies, and start the development server.
   ```bash
   cd frontend
   npm install
   npm run dev
   ```
   > *For more detailed instructions, please refer to the [Frontend README](./frontend/README.md).*

---

## Tooling & Ecosystem

### Backend
- **Framework:** NestJS
- **Data Access:** TypeORM
- **Database:** PostgreSQL
- **Testing:** Jest
- **Docs:** Swagger UI

### Frontend
- **Framework:** React 18
- **Tooling:** Vite
- **Routing:** React Router DOM
- **Testing:** Vitest
