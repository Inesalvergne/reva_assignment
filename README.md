# Review Explorer Page

A Rails application for importing and analyzing customer reviews from multiple channels with automatic Net Promoter Score calculation.

## Tech Stack

- **Rails Version**: 7.2
- **Ruby Version**: 3.2.2
- **Database**: PostgreSQL
- **Frontend**: Tailwind CSS + Hotwire (Turbo + Stimulus)
- **Key Dependencies**: `pagy` (pagination), `pg_search` (full-text search), `sidekiq` (job queue adapter)

## Setup

### Prerequisites
- **Rails**: 7.2
- **Ruby**: 3.2.2
- **PostgreSQL**: 9.3 or higher
- **Bundler**: Latest version

### Installation & commands

1. **Install dependencies**
   
   Run ```bundle install```

3. **Quick setup for development**
   
   Run ```rake dev_setup```

   This command will:
   - Drop, create, and migrate the database
   - Import sample reviews from the CSV file
   - Calculate today's NPS scores globally and for each company

  4. **Running the application**

     Start Rails server with `./bin/dev`
   
     Visit the page at `http://localhost:3000/`

  5. **Running the importer**

     Run `rake reviews:import[path/to/file.csv]`. It's safe to run the task several times with the same file, duplicates won't be imported.

  6. **Trigger the NPS calculation**

     Run `rake nps:calculate_daily_nps`. The NPS is only calculated and stored in the DB once a day.

## CSV Import Feature

### Sample CSV Line

```csv
company_name,date,rating,channel,title,description
Brentwood Property Group,2024-11-18,5,Google,,“The best Airbnb property manager in Indianapolis!”
```

### Column Mapping

| CSV Column      | Database Field     | Type    | Notes                                    |
|-----------------|--------------------|---------|------------------------------------------|
| `company_name`  | `company.name`     | String  | Creates company if it doesn’t exist      |
| `date`          | `review.date`      | Date    | Format: YYYY-MM-DD                       |
| `rating`        | `review.rating`    | Integer | See rating normalization below           |
| `channel`       | `review.channel`   | Enum    | airbnb, google, internal, vrbo           |
| `title`         | `review.title`     | String  | Optional, can be blank                   |
| `description`   | `review.description`| Text   | Used for full-text search                |

### Rating normalization

The importer converts 10-point rating scales to a 5-point rating scale to accommodate different review sources. Only the channel 'Internal' was identified as using a 10-point scale, so the conversion is only made for this channel.

**Conversion**:
  - 10, 9 → 5
  - 8, 7 → 4
  - 6, 5 → 3
  - 4, 3 → 2
  - 2, 1 → 1

**Why**: The normalization ensures consistent NPS calculations across all channels.

**Improvement**: This system might not perfectly represent the original intent. In the future, we should store both the original rating and the normalized rating separately. 

### Duplicate detection

Reviews are considered duplicated based on the combination of: `date`, `rating`, `channel`, `description`, `company_id`. 

`title` was not taken into account because it's often empty.

A unique database index prevents duplicate imports. This ensures data integrity. The importer skips duplicates and reports them at the end of the import process. 

**Tradeoff**:  This means that reviews with the same data and empty descriptions are treated as duplicates. This could be discussed because multiple users could have submitted the same empty review on the same day and via the same channel. However, this edge case was only observed for one company (_Brentwood Property Group_), so this type of duplicate is treated as a data import error.

## Review Explorer UI 

**Features implemented:**
- Paginated table with 14 reviews per page
- Multi-select filters: ratings, channels, companies
- Date range picker
- Full-text search on descriptions (prefix allowed)
- Filters persist in URL query string (shareable links)
- Turbo Frame updates without page reload

**Design decisions:** 
- Sidebar filters: It's always visible for quick adjustments
- Truncated descriptions: It's assumed that, in the future, we'll create a show page for reviews. In the table, the description is truncated to 60 characters to keep the table scannable.
- Title column: Although the title column is often empty, I kept it to show that it was correctly imported. However, it doesn't seem to be key information, so I'd remove the title column and only include it in the show page.

## Daily NPS roll-up feature 

**Rating Classification**:
- **Promoters**: Rating = 5 (highly satisfied customers)
- **Passives**: Rating = 4 (satisfied but unenthusiastic)
- **Detractors**: Rating = 1, 2, or 3 (unhappy customers)
  
**NPS Formula**: ```NPS = ((Promoters - Detractors) / Total Reviews) × 100```

**How to trigger the calculation:**
For now, the rake task `nps:calculate_daily_nps` is triggered manually during the setup. The NPS score can only be calculated once per day. In the future, this could be used to analyze trends.

**In production**: 
In Heroku, we should use a dedicated scheduler task to trigger the calculation. Sidekiq was configured as the job queue adapter. We would also need to set up a Redis database to make this feature work.

**Design decisions:**
- Semicircle gauge with color-coded zones to make the score immediately interpretable
- Visible raw numbers with percentages to allow users to assess statistical significance
- Positioned in sidebar, with real-time updates: so it's always visible, and users can see how selecting a company affects the overall score


## Trade-offs & future work 

**Current trade-offs**

1. No authentication implemented:
   - Why: Simpler setup for the assignment. The page is accessible to everyone.
   - To-do: Implement Devise and ensure authentication is implemented for Sidekiq in production. Right now, Sidekiq Web UI is only accessible in development. 

2. No testing
   - Why: Given the time constraints and the nature of the task, the emphasis was placed on the front-end rather than testing.
   - To-do: I'd give priority to testing the models and the NPS calculation. 
  
3. Pagination UX improvements
     - Why: time constraints
     - To-do: make it easier to jump to a specific page + let users choose how many rows they can see on the page

4. Internationalization
   
   Ideally, we would use i18n keys for a better separation of concerns (text separate from code), easier maintenance, and anticipate the need for various languages.
    - Why: Not necessary for a prototype
    - To-do: install gem `rails-i18n` and use locale yml files for texts

**Ideas for future enhancements**

- Historical NPS trends: Show NPS over time with charts
- Email notifications: alert companies when the NPS has significantly dropped
- Scheduled report: Automated weekly/monthly NPS summary emails
- Export functionality: allow users to export filtered reviews to CSV files
