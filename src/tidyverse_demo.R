library(tidyverse)

glimpse(mtcars)

df <- mtcars %>%
    arrange(desc(mpg)) %>%
    mutate(id = seq(1:nrow(mtcars)),
           fct_cyl = factor(cyl, levels = c(4, 6, 8)))

df %>%
    group_by(cyl) %>%
    summarize(N = n(),
              mean(mpg), median(mpg),
              mean(qsec), median(qsec))

ggplot(df, aes(hp, qsec, color = fct_cyl)) +
    geom_point() +
    ggthemes::theme_tufte()

ggplot(df, aes(hp, qsec)) +
    geom_point() +
    geom_smooth(method = "lm") +
    ggthemes::theme_tufte()

write_csv(df, 'cars.csv')
