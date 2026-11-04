library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(dayalike)

categories <- activity_categories

example_days <- list(
  "An office worker's weekday" = c(
    sleep = 7.5, personal_care = 0.75, eating = 1, work = 9, housework = 1,
    screen = 2.5, travel = 1.5, exercise = 0.5, socialising = 0.25
  ),
  "A uni student's class day" = c(
    sleep = 8, personal_care = 0.75, eating = 1.5, education = 6, screen = 3,
    socialising = 1.5, travel = 1.25, other_leisure = 1, exercise = 0.5,
    housework = 0.5
  ),
  "A parent's busy Saturday" = c(
    sleep = 7.5, personal_care = 0.75, eating = 1.5, childcare = 3,
    housework = 3, shopping_services = 1.5, travel = 2, socialising = 2,
    screen = 1.5, exercise = 0.75, other_leisure = 0.5
  ),
  "A lazy Sunday" = c(
    sleep = 10, personal_care = 0.5, eating = 1.5, housework = 1, screen = 7,
    socialising = 1.5, other_leisure = 2, travel = 0.5
  ),
  "Start from scratch" = c(sleep = 0)
)

hours_input <- function(category) {
  numericInput(
    inputId = category,
    label = categories$label[categories$category == category],
    value = 0, min = 0, max = 24, step = 0.25
  )
}

hours_text <- function(hours) {
  paste(round(hours, 1), "hours")
}

ui <- page_navbar(
  title = "Whose Day Is It?",
  theme = bs_theme(
    version = 5,
    bg = "#FFFDF8",
    fg = "#1F2933",
    primary = "#2F6F73",
    secondary = "#D1495B"
  ),
  header = tags$head(tags$link(rel = "stylesheet", href = "styles.css")),

  nav_panel(
    "Your day",
    layout_sidebar(
      fillable = FALSE,
      sidebar = sidebar(
        width = 330,
        h5("1. Describe one day"),
        p(class = "help-text",
          "Enter the hours you spent on each activity during one recent day,",
          "from waking up to waking up the next morning. Use quarter hours",
          "(0.25 = 15 minutes) and leave activities you did not do at 0."),
        selectInput("example", "Start from an example day",
                    choices = names(example_days)),
        layout_columns(
          col_widths = c(6, 6),
          hours_input("sleep"),
          hours_input("work"),
          hours_input("education"),
          hours_input("housework"),
          hours_input("childcare"),
          hours_input("screen"),
          hours_input("socialising"),
          hours_input("travel")
        ),
        checkboxInput("show_more", "Show 7 more activities", value = FALSE),
        conditionalPanel(
          "input.show_more",
          layout_columns(
            col_widths = c(6, 6),
            hours_input("personal_care"),
            hours_input("eating"),
            hours_input("adult_care"),
            hours_input("shopping_services"),
            hours_input("other_leisure"),
            hours_input("exercise"),
            hours_input("religious_volunteer")
          )
        ),
        div(class = "total-box", textOutput("total_text"))
      ),

      div(
        class = "intro",
        h4("Which kind of day did you have?"),
        p("This app is for anyone curious about how they spend their time.",
          "It compares your day with eight types of day found in the diaries",
          "of 6,146 people in the 2025 American Time Use Survey, tells you",
          "which type yours looks most like, and shows what makes it similar",
          "or different.")
      ),

      uiOutput("headline"),

      card(
        card_header("2. What makes your day this type?"),
        selectInput("compare_with", "Compare my day with",
                    choices = c("My best match",
                                levels(day_types$day_type))),
        plotOutput("compare_plot", height = "460px"),
        p(class = "help-text",
          "Red dots are your hours; grey dots are the average day of the",
          "type you chose. The longer the line, the bigger the difference.",
          "Activities are sorted from the biggest difference to the smallest,",
          "so the top rows explain most of the match.")
      ),
      card(
        card_header("3. How close is each type?"),
        plotOutput("rank_plot", height = "320px"),
        p(class = "help-text",
          "Each bar is roughly how many hours of your day would have to move",
          "from one activity to another to look like that type's average day.",
          "Shorter bars mean a closer match. The dashed line marks a close",
          "match: 95% of real survey days are within that many hours of",
          "their closest type.")
      )
    )
  ),

  nav_panel(
    "The eight types",
    div(
      class = "intro",
      h4("Eight types of day, and who has them"),
      p("Each type is the average of the real diary days grouped into it.",
        "Percentages describe the days of each type: for example, how many of",
        "them were weekends, or were had by people who are employed.")
    ),
    plotOutput("types_plot", height = "640px", fill = FALSE),
    tableOutput("types_table")
  ),

  nav_panel(
    "About the data",
    div(
      class = "intro about",
      h4("Where the data come from"),
      p("The American Time Use Survey (ATUS) asks people aged 15 and over to",
        "describe everything they did on one day, from 4am to 4am. This app",
        "uses the 6,146 diaries collected in 2025 by the U.S. Bureau of Labor",
        "Statistics. The survey's activity codes were grouped into 15",
        "everyday categories, and the days were grouped into eight types",
        "with weighted k-means clustering, using the survey weights so that",
        "results represent all days of the year."),
      h4("Things to keep in mind"),
      tags$ul(
        tags$li("A type describes a day, not a person. The same person can",
                "have a Work day on Monday and a Recharge day on Sunday."),
        tags$li("Days change gradually, so the types are useful summaries,",
                "not sharp boxes. A day can sit between two types."),
        tags$li("The data describe people in the United States in 2025.",
                "Days elsewhere, or in other years, may look different."),
        tags$li("Your hours are your own estimate; diary data are recorded",
                "activity by activity and are usually more precise.")
      ),
      p("Source: U.S. Bureau of Labor Statistics, American Time Use Survey",
        "2025, Activity Summary file",
        tags$a(href = "https://www.bls.gov/tus/", "(bls.gov/tus)."),
        "BLS data are in the public domain.")
    )
  )
)

server <- function(input, output, session) {

  observeEvent(input$example, {
    day <- example_days[[input$example]]
    for (category in categories$category) {
      if (category %in% names(day)) {
        value <- day[[category]]
      } else {
        value <- 0
      }
      updateNumericInput(session, category, value = value)
    }
  })

  my_day <- reactive({
    hours <- c()
    for (category in categories$category) {
      req(!is.null(input[[category]]))
      hours[category] <- input[[category]]
    }
    validate(
      need(!anyNA(hours),
           "Every activity needs a number. Use 0 for activities you did not do.")
    )
    validate(
      need(all(hours >= 0), "Hours cannot be negative."),
      need(sum(hours) > 0,
           "Enter the hours you spent on at least one activity, or choose an example day."),
      need(sum(hours) <= 24,
           paste0("Your day adds up to ", sum(hours), " hours, but a day has ",
                  "only 24. Take ", sum(hours) - 24, " hours off somewhere."))
    )
    hours
  })

  matches <- reactive(match_my_day(my_day()))

  best <- reactive(matches()[1, ])

  compare_type <- reactive({
    if (input$compare_with == "My best match") {
      as.character(best()$day_type)
    } else {
      input$compare_with
    }
  })

  comparison <- reactive(compare_day(my_day(), compare_type()))

  output$total_text <- renderText({
    total <- 0
    for (category in categories$category) {
      value <- input[[category]]
      if (!is.null(value) && !is.na(value)) {
        total <- total + value
      }
    }
    if (total > 24) {
      paste0("Total: ", total, " of 24 hours. That is ", total - 24,
             " hours too many.")
    } else if (total < 24) {
      paste0("Total: ", total, " of 24 hours. ", 24 - total,
             " hours are not assigned to any activity yet.")
    } else {
      "Total: 24 of 24 hours. Every hour is accounted for."
    }
  })

  output$headline <- renderUI({
    top <- best()
    info <- filter(day_types, day_type == top$day_type)
    runner_up <- matches()[2, ]
    unassigned <- 24 - sum(my_day())

    note <- NULL
    if (unassigned > 2) {
      note <- p(class = "warning-text",
        hours_text(unassigned), "of your day is not assigned to any activity,",
        "so your day looks emptier than real diary days. Add the missing hours",
        "for a fairer match.")
    }

    if (top$close_match) {
      card(
        class = "headline-card",
        card_body(
          p(class = "kicker", "Your day looks most like a"),
          h2(top$day_type),
          p(class = "tagline", top$tagline),
          p("About", hours_text(top$hours_apart), "of your day would need to move to",
            "match its average day. The next closest type is",
            strong(as.character(runner_up$day_type)),
            paste0("(about ", hours_text(runner_up$hours_apart), " away).")),
          p(class = "who",
            paste0(round(info$share), "% of days in the survey are of this ",
                   "type. ", round(info$pct_weekend), "% of them fall on a ",
                   "weekend, ", round(info$pct_employed), "% are had by ",
                   "employed people, and the average age is ",
                   round(info$mean_age), ".")),
          note
        )
      )
    } else {
      card(
        class = "headline-card no-match",
        card_body(
          p(class = "kicker", "Your day is one of a kind"),
          h2("No type fits closely"),
          p("Your day is further from every type than 95% of real survey days",
            "are from their closest type. The closest is",
            strong(as.character(top$day_type)),
            paste0("(about ", hours_text(top$hours_apart), " away),"),
            "but read the comparison below with care: the activities at the",
            "top show what makes your day unusual."),
          note
        )
      )
    }
  })

  output$compare_plot <- renderPlot({
    comparison() |>
      filter(you > 0 | typical > 0.05) |>
      mutate(label = factor(label, levels = rev(label))) |>
      ggplot(aes(y = label)) +
      geom_segment(aes(x = typical, xend = you, yend = label),
                   colour = "#CBD2D9", linewidth = 2) +
      geom_point(aes(x = typical, colour = "Average"), size = 4) +
      geom_point(aes(x = you, colour = "You"), size = 4) +
      scale_colour_manual(values = c(You = "#D1495B", Average = "#9AA5B1")) +
      scale_x_continuous(breaks = seq(0, 24, 2)) +
      labs(title = paste("Your day vs the average", compare_type()),
           x = "Hours in the day", y = NULL, colour = NULL) +
      theme_minimal(base_size = 15) +
      theme(legend.position = "top",
            panel.grid.minor = element_blank(),
            panel.grid.major.y = element_blank())
  })

  output$rank_plot <- renderPlot({
    matches() |>
      mutate(day_type = factor(day_type, levels = rev(day_type)),
             match = if_else(rank == 1, "Best match", "Other types")) |>
      ggplot(aes(x = hours_apart, y = day_type, fill = match)) +
      geom_col(width = 0.7) +
      geom_vline(xintercept = day_types$match_cutoff[1], linetype = "dashed",
                 colour = "#52606D") +
      scale_fill_manual(values = c("Best match" = "#D1495B",
                                   "Other types" = "#9FC2C4"),
                        guide = "none") +
      labs(x = "Hours to move", y = NULL) +
      theme_minimal(base_size = 15) +
      theme(panel.grid.minor = element_blank(),
            panel.grid.major.y = element_blank())
  })

  output$types_plot <- renderPlot({
    day_type_profiles |>
      left_join(select(categories, category, label), by = "category") |>
      mutate(hours = minutes / 60,
             label = factor(label, levels = rev(categories$label))) |>
      ggplot(aes(x = hours, y = label)) +
      geom_col(fill = "#2F6F73") +
      facet_wrap(~day_type, nrow = 2) +
      labs(x = "Average hours per day", y = NULL) +
      theme_minimal(base_size = 14) +
      theme(panel.grid.minor = element_blank(),
            panel.grid.major.y = element_blank(),
            strip.text = element_text(face = "bold", size = 14))
  })

  output$types_table <- renderTable({
    day_types |>
      transmute(
        `Day type` = day_type,
        `What it looks like` = tagline,
        `Share of days` = paste0(round(share), "%"),
        `On a weekend` = paste0(round(pct_weekend), "%"),
        `Average age` = as.character(round(mean_age)),
        `Women` = paste0(round(pct_female), "%"),
        `Employed` = paste0(round(pct_employed), "%"),
        `Students` = paste0(round(pct_student), "%"),
        `Child under 6 at home` = paste0(round(pct_child_under_6), "%"),
        `Aged 65+` = paste0(round(pct_aged_65_plus), "%")
      )
  }, striped = TRUE, width = "100%")
}

shinyApp(ui, server)
