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

## CSV Import Feature

### Sample CSV Line

```csv
company_name,date,rating,channel,title,description
Brentwood Property Group,2024-11-18,5,Google,,“The best Airbnb property manager in Indianapolis!”
```

### Column Mapping

| CSV Column      | Database Field     | Type    | Notes                                    |
|-----------------|--------------------|---------|------------------------------------------|
| `company_name`  | `company.name`     | String  | Auto-creates company if doesn’t exist    |
| `date`          | `review.date`      | Date    | Format: YYYY-MM-DD                       |
| `rating`        | `review.rating`    | Integer | See rating normalization below           |
| `channel`       | `review.channel`   | Enum    | airbnb, google, internal, vrbo           |
| `title`         | `review.title`     | String  | Optional, can be blank                   |
| `description`   | `review.description`| Text   | Used for full-text search                |

**Rating normalization** 

The importer converts 10-point rating scales to a 5-point rating scale to accommodate different review sources.

Conversion for rating between 6 and 10:
  - 10, 9 → 5
  - 8, 7 → 4
  - 6 → 3

**Why**: The normalization ensures consistent NPS calculations across all channels.

**Improvement**: This system might not perfectly represent the original intent. In the future we could store both the original rating and the normalized rating separately. 

**Duplicate detection**

Reviews are considered duplicated based on the combination of: `date`, `rating`, `channel`, `description`, `company_id`. `title` was not taken into account because it's often empty.

A unique database index prevents duplicate imports. This ensures data integrity. The importer skips duplicates and report them at the end of the import process. 

**Tradeoff**:  This means that reviews with the same data and empty descriptions are treated as duplicates. This could be discussed because multiple users could have submitted the same empty review on the same day and via same channel. But, the data suggests that it’s rather an import error, because this edge case was only observed for one company (_Brentwood Property Group_).

## Daily NPS roll-up feature 

**Rating Classification**:
- **Promoters**: Rating = 5 (highly satisfied customers)
- **Passives**: Rating = 4 (satisfied but unenthusiastic)
- **Detractors**: Rating = 1, 2, or 3 (unhappy customers)
  
**NPS Formula**: ```NPS = ((Promoters - Detractors) / Total Reviews) × 100```

**How to trigger the calculation:**
For now, the rake task `nps:calculate_daily_nps` is triggered manually during the setup. In production, it should be triggered every day. For instance, we could use a dedicated scheduler task in Heroku.

## Trade-offs & future work 

**Current trade-offs**

1. No authentication implemented:
   - Why: Simpler setup for the assignment. The page is accessible by everyone.
   - To-do: Implement Devise

2. No testing
   - Why: Given the time constraints and the nature of the task, the emphasis was placed on the front-end rather than testing.
   - To-do: 
  
3. Pagination UX improvements
  - Why: time constraints
  - To-do: make it easier to jump to a specific page + let users choose how many rows they can see on the page 

**Ideas for future enhancements**

- Historical NPS trends: Show NPS over time with charts
- Email notifications: alert companies when the NPS has significantly dropped
- Scheduled report: Automated weekly/monthly NPS summary emails
- Export functionality: allow users to export filtered reviews to CSV files
