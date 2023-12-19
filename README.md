# CodeLearn API

Welcome to the CodeLearn API repository! This project is built using Ruby on Rails, Grape API, JWT (JSON Web Tokens), and Swagger. It provides a robust backend for a web blog application, allowing you to create, retrieve, update, and delete blog posts, comments, and more through a RESTful API.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
  - [Installation](#installation)
- [JWT Authentication](#jwt-authentication)
- [Swagger Documentation](#swagger-documentation)
- [Contributing](#contributing)
- [License](#license)

## Features

- User authentication and authorization using JWT.
- CRUD operations for blog posts, comments, and user profiles.
- API documentation using Swagger.
- Consistent and clean codebase following Ruby on Rails best practices.

## Prerequisites

Before you begin, ensure you have the following prerequisites installed:

- Ruby (version 3.2.0)
- Ruby on Rails (version 7.0)

## Getting Started

### Installation

1. Clone the repository:

   ```bash
   git clone git@github.com:tuanle03/code_learn_api.git
   cd code_learn_api
   ```
   
2. Install dependencies:
    ```bash
   bundle install
   ```
3. Set up the database:
   ```bash
   rails db:create db:migrate
   ```
4. Start project
   ```bash
   rails server
   ```
## JWT Authentication
This project uses JSON Web Tokens (JWT) for user authentication. Make sure to include the JWT token in the Authorization header of your requests:
   ```bash
   Authorization: Bearer YOUR_JWT_TOKEN
   ```

## Swagger Documentation
Explore the API endpoints and test them using the Swagger documentation at `http://localhost:2106/api/web/doc`.

## Contributing
We welcome contributions! If you find a bug or have an enhancement in mind, please open an issue or submit a pull request.

## License
This project is licensed under the MIT License.

Happy coding!
   
