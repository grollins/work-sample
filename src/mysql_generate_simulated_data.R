library(tidyverse)
library(DBI)
library(RMySQL)

N <- 1e4

id <- as.integer(runif(N, 1e3, 1e6))

country_vec <- c('US', 'CA', 'NO', 'UK', 'AU', 'NZ', 'FR', 'JP')
country_prob <- c(0.5, 0.1, 0.05, 0.15, 0.01, 0.030, 0.08, 0.08)
country_sample <- sample(country_vec, N, replace = T, prob = country_prob)
country_sample %>% table() %>% prop.table()

plan_vec <- c('Premium', 'Standard', 'Free')
plan_prob <- c(0.01, 0.20, 0.79)
plan_sample <- sample(plan_vec, N, replace = T, prob = plan_prob)
plan_sample %>% table() %>% prop.table()

activity_sample <- list()
activity_sample[['Premium']] <- rbinom(N, 14, 0.8)
activity_sample[['Standard']] <- rbinom(N, 14, 0.5)
activity_sample[['Free']] <- rbinom(N, 14, 0.05)

df <- data_frame(id = id, country = country_sample, plan = plan_sample,
                 activity1 = activity_sample[['Premium']],
                 activity2 = activity_sample[['Standard']],
                 activity3 = activity_sample[['Free']])

df2 <- df %>%
    mutate(activity = ifelse(plan == 'Premium', activity1,
                             ifelse(plan == 'Standard', activity2,
                                    activity3))) %>%
    select(-activity1, -activity2, -activity3)

df2 %>%
    group_by(plan, country) %>%
    summarize(n()) %>%
    View()

ggplot(df2, aes(plan, activity, fill = plan)) +
    geom_violin(draw_quantiles = c(0.5),
                adjust = 1.0) +
    facet_wrap(~country) +
    ggthemes::theme_few()

# /usr/local/Cellar/mysql/5.7.18/bin/mysql -h localhost -P 32768 --protocol=tcp -uroot -p
# CREATE DATABASE test CHARACTER SET utf8;
# USE test;
# CREATE TABLE user (id INT, country VARCHAR(2), plan VARCHAR(50), PRIMARY KEY (id));
# DROP TABLE user;

country_df <- df2 %>% select(id, country)
activity_df <- df2 %>% select(id, activity)
plan_df <- df2 %>% select(id, plan)

# connect to local docker db
con <- dbConnect(RMySQL::MySQL(), "test", "root", Sys.getenv('DOCKER_MYSQL_PW'),
                 host = "127.0.0.1", port = 32770)

dbWriteTable(con, "user_country", country_df)
dbWriteTable(con, "user_activity", activity_df)
dbWriteTable(con, "user_plan", plan_df)
