# Multi-Tenant Opera Singer Websites

## Building Sites

```
TENANT=hugohymascom bundle exec middleman build
TENANT=benkazezcom bundle exec middleman build
```

## Development

```
cd netlify/hugohymascom
netlify dev

cd netlify/benkazezcom  
netlify dev
```

## Key Info

- Uses TENANT environment variable to switch between sites
- Each tenant has data in `data/hugohymascom/` and `data/benkazezcom/`
- Tenant assets in `source/tenants/hugohymascom/` and `source/tenants/benkazezcom/`
- Separate stylesheets: `hugohymascom.css.scss` and `benkazezcom.css.scss`

## Events System

Events support copy_from to reuse data:

```
- date: 2025-01-01
  venue: Main Venue
  rep: Bach Cantata
  
- copy_from: 2025-01-01
  date: 2025-01-02
  venue: Different Venue
```

Remote events are loaded from the calendar specified in each tenant's site.yml.