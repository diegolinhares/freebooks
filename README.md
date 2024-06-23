# README

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
