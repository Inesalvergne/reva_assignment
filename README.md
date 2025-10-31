# Review Explorer Page

A Rails application for importing and analyzing customer reviews from multiple channels with automatic Net Promoter Score calculation.

## Tech Stack

- **Rails Version**: 7.2
- **Ruby Version**: 3.2.2
- **Database**: PostgreSQL
- **Frontend**: Tailwind CSS + Hotwire (Turbo + Stimulus)
- **Key Dependencies**: `pagy` (pagination), `pg_search` (full-text search)

## Setup

### Prerequisites
- **Rails**: 7.2
- **Ruby**: 3.2.2
- **PostgreSQL**: 9.3 or higher
- **Bundler**: Latest version

### Installation 

1. **Install dependencies**
   
   Run ```bundle install```

3. **Quick setup for development**
   
   Run ```rake dev_setup```

   This command will:
   - Drop, create, and migrate the database
   - Import sample reviews from the CSV file
   - Calculate NPS scores globally and for all companies

  4. **Running the application**

  Start Rails server with `./bin/dev`

  Visit the page at `http://localhost:3000/`
   

