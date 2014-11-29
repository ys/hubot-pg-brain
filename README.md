# Hubot json postgres brain

## Installation

In your hubot repository, run:

```
npm install hubot-pg-brain --save
```

Then add hubot-pg-brain to your external-scripts.json:

```
["hubot-pg-brain"]
```

Before Running the bot, create a postgres database with following schema.

```SQL
CREATE TABLE brain (
key TEXT unique,
value JSON default '{}'::json, 
CONSTRAINT brain_pkey PRIMARY KEY (key)
);
```