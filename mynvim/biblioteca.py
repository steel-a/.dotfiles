class Book:
    def __init__(self, title, author, year, isbn):
        self.title = title
        self.author = author
        self.year = year
        self.isbn = isbn

    def __str__(self):
        return f"{self.title} by {self.author} ({self.year}) [ISBN: {self.isbn}]"

class Library:
    def __init__(self):
        self.books = []

    def add_book(self, book):
        self.books.append(book)
        print(f"Added: {book}")

    def remove_book(self, isbn):
        for book in self.books:
            if book.isbn == isbn:
                self.books.remove(book)
                print(f"Removed: {book}")
                return
        print(f"No book found with ISBN: {isbn}")

    def search_books(self, title=None, author=None):
        results = [book for book in self.books if 
                   (title and title.lower() in book.title.lower()) or 
                   (author and author.lower() in book.author.lower())]
        if results:
            print("Search Results:")
            for book in results:
                print(f"- {book}")
        else:
            print("No books match your search criteria.")

    def display_books(self):
        if not self.books:
            print("Library is empty.")
        else:
            print("Books in Library:")
            for book in self.books:
                print(f"- {book}")

# Example usage
if __name__ == "__main__":
    library = Library()

    book1 = Book("The Catcher in the Rye", "J.D. Salinger", 1951, "123456789")
    book2 = Book("To Kill a Mockingbird", "Harper Lee", 1960, "987654321")
    book3 = Book("1984", "George Orwell", 1949, "111222333")

    library.add_book(book1)
    library.add_book(book2)
    library.add_book(book3)

    library.display_books()

    library.search_books(author="George Orwell")

    library.remove_book("123456789")

    library.display_books()

