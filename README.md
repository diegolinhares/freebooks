# README

Welcome to Freebooks!

**Spoiler:** Some frontend resources were extracted from the [Yataska](https://github.com/yataska) project.

You can check the application running in [this video](https://youtu.be/Cx2iWVKnxkM).

# Tooling

## Versions
- **Ruby**: 3.3.1
- **Rails**: 7.2.0.beta2

## Frontend
- **Hotwire**: Includes gems `turbo-rails` and `stimulus-rails`, used to add Turbo and Stimulus functionality, respectively.
- **Pico**: CSS framework used for web design.

## Database and Storage
- **sqlite**: Connector and adapter for SQLite database.
- **litestack**: Used for improving SQLite, for example, full text search.

## Application Features
- **Pagy**: Lightweight and efficient pagination gem.
- **action-policy**: Create policies for librarians.

## Testing
- **Fixtures**: Instead of FactoryBot, I've used Rails default fixtures. They were used to create the seeds too.
- **Rspec-rails**: Testing framework for Rails.
- **Shoulda-matchers**: Provides simplifications for testing Rails functionality.

# Features Implemented

- [x] Authentication and Authorization

- [x] Book Management

- [x] Borrowing and Returning

- [x] Dashboard

- [x] API Endpoints

- [x] Frontend (Bonus): Implemented using Hotwire

# Testing

Below is a summary of the testing efforts:

- [x] **Models**
  - Comprehensive testing of all models to validate core functionality.

- [x] **Integration Tests (API)**
  - Integration testing of API functionality to ensure proper communication.

## Getting Started

To get started, ensure that you have the following prerequisites installed on your system:

- Ruby (version 3.3.1)
- Rails (version 7.2.0.beta2)

### Setup

1. Clone the repository to your local machine.

```bash
  git clone https://github.com/diegolinhares/freebooks
```

2. Navigate to the project directory.

```bash
  cd freebooks
```

3. Run the following command to set up the project, which will install dependencies, create the database, and perform necessary setup tasks.

```bash
bin/setup
```

### Running the project

```bash
bin/dev
```

This will start the development server, and you can access the application at http://localhost:3000.

### Seed Data

The following user credentials are available for testing:

#### Librarian
- **Email:** librarian@freebooks.com
- **Password:** 12341234
- **Role:** librarian
- **API Access Token:** WJDTXRjAxKoZ8WLxKKmjudLUEUMbzKP3g727QHsqY9

#### Member
- **Email:** samuel_tarly@freebooks.com
- **Password:** 12341234
- **Role:** member
- **API Access Token:** fD7WoV9ZH4qii8KsvwmNKUbSVfsm79rtjwuxgKuCae

### Running tests
```bash
bundle exec rspec spec
```

This command will execute all the tests.

# Solution

### Overview

This project is divided into two contexts: Web and API. For both contexts, we have a "BackOffice" for members and another for librarians.

The controllers in each context handle authentication and authorization by role.

### Implementation

Some actions were basic CRUD operations. I didn't see the need to create services, use cases, or orchestrators. I used the controllers themselves as orchestrators, leveraging the expressiveness of Ruby/Rails.

### Book Borrowing

When a user attempts to borrow a book, I considered that, as a system with a lot of writes, it would be beneficial to use a pessimistic lock. This locks a book while a user is attempting to borrow it, helping to maintain the correct number of available books in a distributed environment. I created a specific attribute for this and compare it with the total number of books that exist.

An interesting challenge was ensuring that members can borrow a book only if it's available and cannot borrow the same book multiple times simultaneously. To solve this, I created a unique index in the database using a constraint and also added a validation at the application level:

```ruby
t.index ["user_id", "book_id"], name: "unique_borrowing_index", unique: true, where: "returned_at IS NULL"
```

### Book Search
Another challenge of this project was the search functionality for books by title, author, or genre. To address this, I used the full-text search feature with trigrams from SQLite, using the Litesearch functionality from the Litestack gem. For pagination, I combined the results with the Pagy gem.

### Fixtures and Seeds
Typically, when using RSpec, you use Factory Bot to create data. However, I preferred to use fixtures and implemented a seed strategy to have the same data in both development and test environments. You can see how this strategy works in the seeds.rb file.

# Database

```mermaid
erDiagram
    USERS {
        string email PK "unique"
        string password_digest
        string role
        string api_access_token PK "unique"
        datetime created_at
        datetime updated_at
    }

    AUTHORS {
        string name PK "unique"
        datetime created_at
        datetime updated_at
    }

    GENRES {
        string name PK "unique"
        datetime created_at
        datetime updated_at
    }

    BOOKS {
        string title
        string isbn PK "unique"
        int total_copies
        int available_copies
        int genre_id FK
        int author_id FK
        datetime created_at
        datetime updated_at
    }

    BORROWINGS {
        int user_id FK
        int book_id FK
        datetime borrowed_at
        datetime due_date
        datetime returned_at
        datetime created_at
        datetime updated_at
    }

    USERS ||--o{ BORROWINGS : "has many"
    BOOKS ||--o{ BORROWINGS : "has many"
    AUTHORS ||--o{ BOOKS : "writes"
    GENRES ||--o{ BOOKS : "categorizes"
```

## Indexes

- **Authors Table:**
  - Unique index on `name`

- **Books Table:**
  - Index on `genre_id`
  - Index on `author_id`
  - Unique index on `isbn`

- **Borrowings Table:**
  - Index on `user_id`
  - Index on `book_id`
  - Unique index on `user_id` and `book_id` where `returned_at` is NULL

- **Genres Table:**
  - Unique index on `name`

- **Users Table:**
  - Unique index on `email`
  - Unique index on `api_access_token`

# API Endpoints

## Members

### Sessions

`POST /api/v1/members/sessions`

#### When Authenticated

```bash
curl -X POST http://localhost:3000/api/v1/members/sessions \
-H "Authorization: Bearer fD7WoV9ZH4qii8KsvwmNKUbSVfsm79rtjwuxgKuCae" \
-H "Content-Type: application/json" \
-d '{
  "user": {
    "email": "samuel.tarly@example.com",
    "password": "12341234"
  }
}'
```

**Expected Response:**

```bash
{
  "status": "error",
  "message": "Action not allowed for authenticated member",
  "details": {}
}
```

#### When Unauthenticated (valid credentials)

```bash
curl -X POST http://localhost:3000/api/v1/members/sessions \
-H "Content-Type: application/json" \
-d '{
  "user": {
    "email": "samuel.tarly@example.com",
    "password": "12341234"
  }
}'
```

**Expected Response:**

```bash
{
  "status": "success",
  "type": "object",
  "data": {
    "access_token": "newly_generated_access_token"
  }
}
```

#### When Unauthenticated (invalid credentials)
```bash
curl -X POST http://localhost:3000/api/v1/members/sessions \
-H "Content-Type: application/json" \
-d '{
  "user": {
    "email": "bad-email",
    "password": "bad-pass"
  }
}'
```

**Expected Response:**

```bash
{
  "status": "error",
  "message": "Invalid email or password",
  "details": {}
}
```

### Delete Session

`DELETE /api/v1/members/sessions`

#### When Authenticated

```bash
curl -X DELETE http://localhost:3000/api/v1/members/sessions \
-H "Authorization: Bearer fD7WoV9ZH4qii8KsvwmNKUbSVfsm79rtjwuxgKuCae" \
-H "Content-Type: application/json"
```

**Expected Response:**

```bash
{
  "status": "success"
}
```

#### When Unauthenticated
```bash
curl -X DELETE http://localhost:3000/api/v1/members/sessions \
-H "Content-Type: application/json"
```

**Expected Response:**

```bash
{
  "status": "error",
  "message": "Invalid access token",
  "details": {}
}
```

### Registration

`POST /api/v1/members/registrations`

#### When Unauthenticated

To register a new member with valid parameters:

```bash
curl -X POST http://localhost:300/api/v1/members/registrations \
-H "Content-Type: application/json" \
-d '{
  "user": {
    "email": "new_member@example.com",
    "password": "password123"
  }
}'
```

**Expected Response:**

```bash
{
  "status": "success",
  "type": "object",
  "data": {
    "message": "Member registered successfully",
    "access_token": "newly_generated_access_token"
  }
}
```

To return an error when parameters are invalid:

```bash
curl -X POST http://localhost:300/api/v1/members/registrations \
-H "Content-Type: application/json" \
-d '{
  "user": {
    "email": "invalid_email",
    "password": ""
  }
}'
```

**Expected Response:**

```bash
{
  "status": "error",
  "message": "Failed to register member",
  "details": [
    "Email is invalid",
    "Password can't be blank"
  ]
}
```

#### When Authenticated

To prevent authenticated members from registering again:

```bash
curl -X POST http://localhost:300/api/v1/members/registrations \
-H "Authorization: Bearer fD7WoV9ZH4qii8KsvwmNKUbSVfsm79rtjwuxgKuCae" \
-H "Content-Type: application/json" \
-d '{
  "user": {
    "email": "new_member@example.com",
    "password": "password123"
  }
}'
```

**Expected Response:**

```bash
{
  "status": "error",
  "message": "Action not allowed for authenticated member",
  "details": {}
}
```
### Borrowings

`GET /api/v1/members/borrowings`

#### When Authenticated

To return paginated borrowings for the current member:

```bash
curl -X GET http://localhost:3000/api/v1/members/borrowings \
-H "Authorization: Bearer fD7WoV9ZH4qii8KsvwmNKUbSVfsm79rtjwuxgKuCae" \
-H "Content-Type: application/json"
```

**Expected Response:**

```bash
{
  "status": "success",
  "type": "object",
  "data": {
    "borrowings": [
      {
        "book_title": "Expired Book",
        "status": "overdue"
      },
      {
        "book_title": "A Game of Thrones",
        "status": "not overdue"
      },
      {
        "book_title": "Dune",
        "status": "not overdue"
      }
    ]
  },
  "pagination": {
    "count": 3,
    "items": 5,
    "next": null,
    "page": 1,
    "pages": 1,
    "prev": null
  }
}
```

#### When Unauthenticated

To return unauthorized status:

```bash
curl -X GET http://localhost:3000/api/v1/members/borrowings \
-H "Content-Type: application/json"
```

**Expected Response:**

```bash
{
  "status": "error",
  "message": "Invalid access token",
  "details": {}
}
```

### Create Borrowing

`POST /api/v1/members/book_borrowings`

#### When Authenticated

To create a borrowing successfully:

```bash
curl -X POST http://localhost:3000/api/v1/members/books/:book_id/borrowings \
-H "Authorization: Bearer fD7WoV9ZH4qii8KsvwmNKUbSVfsm79rtjwuxgKuCae" \
-H "Content-Type: application/json"
```

**Expected Response:**

```bash
{
  "status": "success",
  "data": {
    "message": "Book successfully borrowed."
  },
  "type": "object"
}
```

To fail to create a borrowing when no copies are available:

```bash
curl -X POST http://localhost:3000/api/v1/members/books/:book_id/borrowings \
-H "Authorization: Bearer fD7WoV9ZH4qii8KsvwmNKUbSVfsm79rtjwuxgKuCae" \
-H "Content-Type: application/json"
```

**Expected Response:**

```bash
{
  "status": "error",
  "message": "No available copies to borrow.",
  "details": {}
}
```

To return an error when the user tries to borrow a book they have already borrowed and not returned:

```bash
curl -X POST http://localhost:3000/api/v1/members/books/:book_id/borrowings \
-H "Authorization: Bearer fD7WoV9ZH4qii8KsvwmNKUbSVfsm79rtjwuxgKuCae" \
-H "Content-Type: application/json"
```

**Expected Response:**

```bash
{
  "status": "error",
  "message": "Failed to borrow book",
  "details": ["User has already borrowed this book and not returned it yet"]
}
```

#### When Unauthenticated

To return unauthorized status:

```bash
curl -X POST http://localhost:3000/api/v1/members/books/:book_id/borrowings \
-H "Content-Type: application/json"
```

**Expected Response:**

```bash
{
  "status": "error",
  "message": "Invalid access token",
  "details": {}
}
```

### Get Books

`GET /api/v1/members/books`

#### When Authenticated

To return paginated books for the current member:

```bash
curl -X GET http://localhost:3000/api/v1/members/books \
-H "Authorization: Bearer fD7WoV9ZH4qii8KsvwmNKUbSVfsm79rtjwuxgKuCae" \
-H "Content-Type: application/json"
```

**Expected Response:**

```bash
{
  "status": "success",
  "type": "object",
  "data": {
    "books": [
      {
        "title": "A Feast for Crows",
        "author_name": "George R. R. Martin",
        "genre_name": "Fantasy"
      },
      {
        "title": "Dune",
        "author_name": "Frank Herbert",
        "genre_name": "Science Fiction"
      },
      {
        "title": "A Dance with Dragons",
        "author_name": "George R. R. Martin",
        "genre_name": "Fantasy"
      },
      {
        "title": "The Book Thief",
        "author_name": "Markus Zusak",
        "genre_name": "Historical Fiction"
      },
      {
        "title": "Gone Girl",
        "author_name": "Gillian Flynn",
        "genre_name": "Thriller"
      }
    ]
  },
  "pagination": {
    "count": 16,
    "items": 5,
    "next": 2,
    "page": 1,
    "pages": 4,
    "prev": null
  }
}
```

To return paginated books for the search query "Dune":

```bash
curl -X GET http://localhost:3000/api/v1/members/books?query=Dune \
-H "Authorization: Bearer fD7WoV9ZH4qii8KsvwmNKUbSVfsm79rtjwuxgKuCae" \
-H "Content-Type: application/json"
```

**Expected Response:**

```bash
{
  "status": "success",
  "type": "object",
  "data": {
    "books": [
      {
        "title": "Dune",
        "author_name": "Frank Herbert",
        "genre_name": "Science Fiction"
      }
    ]
  },
  "pagination": {
    "count": 1,
    "items": 5,
    "next": null,
    "page": 1,
    "pages": 1,
    "prev": null
  }
}
```

#### When Unauthenticated

To return unauthorized status:

```bash
curl -X GET http://localhost:3000/api/v1/members/books \
-H "Content-Type: application/json"
```

**Expected Response:**

```bash
{
  "status": "error",
  "message": "Invalid access token",
  "details": {}
}
```

## Librarians

### Create Session

`POST /api/v1/librarians/sessions`

#### When Authenticated

To avoid re-authenticating the user:

```bash
curl -X POST http://localhost:3000/api/v1/librarians/sessions \
-H "Authorization: Bearer WJDTXRjAxKoZ8WLxKKmjudLUEUMbzKP3g727QHsqY9" \
-H "Content-Type: application/json" \
-d '{
  "user": {
    "email": "librarian@freebooks.com",
    "password": "12341234"
  }
}'
```

**Expected Response:**

```bash
{
  "status": "error",
  "message": "Action not allowed for authenticated librarian",
  "details": {}
}
```

#### When Unauthenticated

To authenticate the user when parameters are valid:

```bash
curl -X POST http://localhost:3000/api/v1/librarians/sessions \
-H "Content-Type: application/json" \
-d '{
  "user": {
    "email": "librarian@freebooks.com",
    "password": "12341234"
  }
}'
```

**Expected Response:**

```bash
{
  "status": "success",
  "type": "object",
  "data": {
    "access_token": "newly_generated_access_token"
  }
}
```

To avoid authenticating the user when parameters are invalid:

```bash
curl -X POST http://localhost:3000/api/v1/librarians/sessions \
-H "Content-Type: application/json" \
-d '{
  "user": {
    "email": "bad-email",
    "password": "bad-pass"
  }
}'
```

**Expected Response:**

```bash
{
  "status": "error",
  "message": "Invalid email or password",
  "details": {}
}
```

### Delete Session

`DELETE /api/v1/librarians/sessions`

#### When Authenticated

To sign out the current librarian and regenerate the API access token:

```bash
curl -X DELETE http://localhost:3000/api/v1/librarians/sessions \
-H "Authorization: Bearer WJDTXRjAxKoZ8WLxKKmjudLUEUMbzKP3g727QHsqY9" \
-H "Content-Type: application/json"
```

**Expected Response:**

```bash
{
  "status": "success"
}
```

#### When Unauthenticated

To return unauthorized status:

```bash
curl -X DELETE http://localhost:3000/api/v1/librarians/sessions \
-H "Content-Type: application/json"
```

**Expected Response:**

```bash
{
  "status": "error",
  "message": "Invalid access token",
  "details": {}
}
```

### Create Registration

`POST /api/v1/librarians/registrations`

#### When Unauthenticated

To register a new librarian and return access token:

```bash
curl -X POST http://localhost:3000/api/v1/librarians/registrations \
-H "Content-Type: application/json" \
-d '{
  "user": {
    "email": "librarian@example.com",
    "password": "password123"
  }
}'
```

**Expected Response:**

```bash
{
  "status": "success",
  "data": {
    "message": "Librarian registered successfully",
    "access_token": "newly_generated_access_token"
  },
  "type": "object"
}
```

To return errors when registration fails:

```bash
curl -X POST http://localhost:3000/api/v1/librarians/registrations \
-H "Content-Type: application/json" \
-d '{
  "user": {
    "email": "",
    "password": "password123"
  }
}'
```

**Expected Response:**

```bash
{
  "status": "error",
  "message": "Failed to register librarian",
  "details": ["Email can't be blank"]
}
```

#### When Authenticated

To disallow authenticated librarian from registering:

```bash
curl -X POST http://localhost:3000/api/v1/librarians/registrations \
-H "Authorization: Bearer WJDTXRjAxKoZ8WLxKKmjudLUEUMbzKP3g727QHsqY9" \
-H "Content-Type: application/json" \
-d '{
  "user": {
    "email": "librarian2@example.com",
    "password": "password123"
  }
}'
```

**Expected Response:**

```bash
{
  "status": "error",
  "details": {},
  "message": "Action not allowed for authenticated librarian"
}
```

### Get Statistics

`GET /api/v1/librarians/statistics`

#### When Authenticated

To return dashboard statistics for the librarian:

```bash
curl -X GET http://localhost:3000/api/v1/librarians/statistics \
-H "Authorization: Bearer WJDTXRjAxKoZ8WLxKKmjudLUEUMbzKP3g727QHsqY9" \
-H "Content-Type: application/json"
```

**Expected Response:**

```bash
{
  "status": "success",
  "data": {
    "books": 17,
    "total_borrowed_books": 13,
    "books_due_today": 0
  },
  "type": "object"
}
```

#### When Unauthenticated

To return unauthorized status:

```bash
curl -X GET http://localhost:3000/api/v1/librarians/statistics \
-H "Content-Type: application/json"
```

**Expected Response:**

```bash
{
  "status": "error",
  "message": "Invalid access token",
  "details": {}
}
```

### Get Members

`GET /api/v1/librarians/members`

#### When Authenticated

To return paginated members with overdue books:

```bash
curl -X GET http://localhost:3000/api/v1/librarians/members \
-H "Authorization: Bearer WJDTXRjAxKoZ8WLxKKmjudLUEUMbzKP3g727QHsqY9" \
-H "Content-Type: application/json"
```

**Expected Response:**

```bash
{
  "status": "success",
  "data": {
    "members": [
      {
        "email": "member1@example.com"
      },
      {
        "email": "member2@example.com"
      },
      ...
    ]
  },
  "pagination": {
    "count": 10,
    "items": 5,
    "next": 2,
    "page": 1,
    "pages": 2,
    "prev": null
  },
  "type": "object"
}
```

#### When Unauthenticated

To return unauthorized status:

```bash
curl -X GET http://localhost:3000/api/v1/librarians/members \
-H "Content-Type: application/json"
```

**Expected Response:**

```bash
{
  "status": "error",
  "message": "Invalid access token",
  "details": {}
}
```

### Get Books

`GET /api/v1/librarians/books`

#### When Authenticated

To return paginated books for the librarian:

```bash
curl -X GET http://localhost:3000/api/v1/librarians/books \
-H "Authorization: Bearer WJDTXRjAxKoZ8WLxKKmjudLUEUMbzKP3g727QHsqY9" \
-H "Content-Type: application/json"
```

**Expected Response:**

```bash
{
  "status": "success",
  "type": "object",
  "data": {
    "books": [
      {
        "title": "A Feast for Crows",
        "author_name": "George R. R. Martin",
        "genre_name": "Fantasy"
      },
      {
        "title": "Sapiens: A Brief History of Humankind",
        "author_name": "Yuval Noah Harari",
        "genre_name": "Non-fiction"
      },
      {
        "title": "Dune",
        "author_name": "Frank Herbert",
        "genre_name": "Science Fiction"
      },
      {
        "title": "A Dance with Dragons",
        "author_name": "George R. R. Martin",
        "genre_name": "Fantasy"
      },
      {
        "title": "The Book Thief",
        "author_name": "Markus Zusak",
        "genre_name": "Historical Fiction"
      }
    ]
  },
  "pagination": {
    "count": 17,
    "items": 5,
    "next": 2,
    "page": 1,
    "pages": 4,
    "prev": null
  }
}
```

To return paginated books for the search query "Dune":

```bash
curl -X GET http://localhost:3000/api/v1/librarians/books?query=Dune \
-H "Authorization: Bearer WJDTXRjAxKoZ8WLxKKmjudLUEUMbzKP3g727QHsqY9" \
-H "Content-Type: application/json"
```

**Expected Response:**

```bash
{
  "status": "success",
  "type": "object",
  "data": {
    "books": [
      {
        "title": "Dune",
        "author_name": "Frank Herbert",
        "genre_name": "Science Fiction"
      }
    ]
  },
  "pagination": {
    "count": 1,
    "items": 5,
    "next": null,
    "page": 1,
    "pages": 1,
    "prev": null
  }
}
```

#### When Unauthenticated

To return unauthorized status:

```bash
curl -X GET http://localhost:3000/api/v1/librarians/books \
-H "Content-Type: application/json"
```

**Expected Response:**

```bash
{
  "status": "error",
  "message": "Invalid access token",
  "details": {}
}
```

### Create Book

`POST /api/v1/librarians/books`

#### When Authenticated

To create a book successfully:

```bash
curl -X POST http://localhost:3000/api/v1/librarians/books \
-H "Authorization: Bearer WJDTXRjAxKoZ8WLxKKmjudLUEUMbzKP3g727QHsqY9" \
-H "Content-Type: application/json" \
-d '{
  "book": {
    "title": "New Book",
    "author_id": 1,
    "genre_id": 1,
    "isbn": "978-1234567890",
    "total_copies": 10,
    "available_copies": 10
  }
}'
```

**Expected Response:**

```bash
{
  "status": "success",
  "data": {
    "message": "Book created",
    "book": {
      "title": "New Book"
    }
  },
  "type": "object"
}
```

To fail to create a book due to validation errors:

```bash
curl -X POST http://localhost:3000/api/v1/librarians/books \
-H "Authorization: Bearer WJDTXRjAxKoZ8WLxKKmjudLUEUMbzKP3g727QHsqY9" \
-H "Content-Type: application/json" \
-d '{
  "book": {
    "title": "",
    "author_id": 1,
    "genre_id": 1,
    "isbn": "978-1234567890",
    "total_copies": 10,
    "available_copies": 10
  }
}'
```

**Expected Response:**

```bash
{
  "status": "error",
  "message": "Failed to create book",
  "details": ["Title can't be blank"]
}
```

#### When Unauthenticated

To return unauthorized status:

```bash
curl -X POST http://localhost:3000/api/v1/librarians/books \
-H "Content-Type: application/json" \
-d '{
  "book": {
    "title": "New Book",
    "author_id": 1,
    "genre_id": 1,
    "isbn": "978-1234567890",
    "total_copies": 10,
    "available_copies": 10
  }
}'
```

**Expected Response:**

```bash
{
  "status": "error",
  "message": "Invalid access token",
  "details": {}
}
```

### Update Book

`PUT /api/v1/librarians/books/:id`

#### When Authenticated

To update a book successfully:

```bash
curl -X PUT http://localhost:3000/api/v1/librarians/books/1 \
-H "Authorization: Bearer WJDTXRjAxKoZ8WLxKKmjudLUEUMbzKP3g727QHsqY9" \
-H "Content-Type: application/json" \
-d '{
  "book": {
    "title": "Updated Book Title",
    "author_id": 1,
    "genre_id": 1,
    "isbn": "978-1234567890",
    "total_copies": 10,
    "available_copies": 10
  }
}'
```

**Expected Response:**

```bash
{
  "status": "success",
  "data": {
    "message": "Book updated",
    "book": {
      "title": "Updated Book Title"
    }
  },
  "type": "object"
}
```

To fail to update a book due to validation errors:

```bash
curl -X PUT http://localhost:3000/api/v1/librarians/books/1 \
-H "Authorization: Bearer WJDTXRjAxKoZ8WLxKKmjudLUEUMbzKP3g727QHsqY9" \
-H "Content-Type: application/json" \
-d '{
  "book": {
    "title": "",
    "author_id": 1,
    "genre_id": 1,
    "isbn": "978-1234567890",
    "total_copies": 10,
    "available_copies": 10
  }
}'
```

**Expected Response:**

```bash
{
  "status": "error",
  "message": "Failed to update book",
  "details": ["Title can't be blank"]
}
```

#### When Unauthenticated

To return unauthorized status:

```bash
curl -X PUT http://localhost:3000/api/v1/librarians/books/1 \
-H "Content-Type: application/json" \
-d '{
  "book": {
    "title": "Updated Book Title",
    "author_id": 1,
    "genre_id": 1,
    "isbn": "978-1234567890",
    "total_copies": 10,
    "available_copies": 10
  }
}'
```

**Expected Response:**

```bash
{
  "status": "error",
  "message": "Invalid access token",
  "details": {}
}
```

### Delete Book

`DELETE /api/v1/librarians/books/:id`

#### When Authenticated

To delete a book successfully:

```bash
curl -X DELETE http://localhost:3000/api/v1/librarians/books/1 \
-H "Authorization: Bearer WJDTXRjAxKoZ8WLxKKmjudLUEUMbzKP3g727QHsqY9" \
-H "Content-Type: application/json"
```

**Expected Response:**

```bash
{
  "status": "success"
}
```

#### When Unauthenticated

To return unauthorized status:

```bash
curl -X DELETE http://localhost:3000/api/v1/librarians/books/1 \
-H "Content-Type: application/json"
```

**Expected Response:**

```bash
{
  "status": "error",
  "message": "Invalid access token",
  "details": {}
}
```

### Get Member Borrowings

`GET /api/v1/librarians/members/:member_id/borrowings`

#### When Authenticated

To return paginated borrowings for the member:

```bash
curl -X GET http://localhost:3000/api/v1/librarians/members/1/borrowings \
-H "Authorization: Bearer WJDTXRjAxKoZ8WLxKKmjudLUEUMbzKP3g727QHsqY9" \
-H "Content-Type: application/json"
```

**Expected Response:**

```bash
{
  "status": "success",
  "data": {
    "borrowings": [
      {
        "book_title": "Expired Book"
      },
      {
        "book_title": "A Game of Thrones"
      },
      {
        "book_title": "Dune"
      }
    ]
  }
}
```

#### When Unauthenticated

To return unauthorized status:

```bash
curl -X GET http://localhost:3000/api/v1/librarians/members/1/borrowings \
-H "Content-Type: application/json"
```

**Expected Response:**

```bash
{
  "status": "error",
  "message": "Invalid access token",
  "details": {}
}
```

### Mark Book as Returned

`PATCH /api/v1/librarians/borrowings/:borrowing_id/return`

#### When Authenticated

To mark the book as returned:

```bash
curl -X PATCH http://localhost:3000/api/v1/librarians/borrowings/1/return \
-H "Authorization: Bearer WJDTXRjAxKoZ8WLxKKmjudLUEUMbzKP3g727QHsqY9" \
-H "Content-Type: application/json"
```

**Expected Response:**

```bash
{
  "status": "success",
  "data": {
    "message": "Book marked as returned."
  },
  "type": "object"
}
```

#### When Unauthenticated

To return unauthorized status:

```bash
curl -X PATCH http://localhost:3000/api/v1/librarians/borrowings/1/return \
-H "Content-Type: application/json"
```

**Expected Response:**

```bash
{
  "status": "error",
  "message": "Invalid access token",
  "details": {}
}
```
