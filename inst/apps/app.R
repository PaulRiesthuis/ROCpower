library(shiny)
library(shinydashboard)
library(pROC)
library(MASS)
library(knitr)
library(kableExtra)
library(dplyr)
library(tidyverse)

# Define UI for the application
ui <- dashboardPage(
  dashboardHeader(title = "ROC Simulations"),
  dashboardSidebar(
    width = 400,  # Increase width here
    sidebarMenu(
      menuItem("Power Analysis Explanation", tabName = "power_explanation", icon = icon("info-circle")),
      menuItem("1 - Estimate the AUC - Equal Variance", tabName = "estimate_auc", icon = icon("chart-line")),
      menuItem("2 - Single ROC curve - Equal Variance - Power Analysis", tabName = "single_roc_ev", icon = icon("chart-line")),
      menuItem("3 - Unpaired ROC - Equal Variance Power Analysis", tabName = "unpaired_roc", icon = icon("chart-bar")),
      menuItem("4 - Paired ROC - Equal Variance - Power Analysis", tabName = "paired_roc", icon = icon("chart-bar")),
      menuItem("5 - Estimate the AUC Unequal Variance", tabName = "estimate_auc_uv", icon = icon("chart-line")),
      menuItem("6 - Single ROC curve - Unequal Variance - Power Analysis", tabName = "single_roc_uv", icon = icon("chart-line")),
      menuItem("7 - Unpaired ROC - Unequal Variance - Power Analysis", tabName = "unpaired_roc_uv", icon = icon("chart-bar")),
      menuItem("8 - Paired ROC - Unequal Variance - Power Analysis", tabName = "paired_roc_uv", icon = icon("chart-bar")),
      menuItem("9 - Estimate the pAUC - Equal + Unequal Variance", tabName = "estimate_pauc", icon = icon("chart-line"))

    )
  ),
  dashboardBody(
    tabItems(
      # Info Tab: Explanation Explanation
      tabItem(tabName = "power_explanation",
              fluidPage(
                titlePanel("Power Analysis and AUC Estimation Explanation"),
                fluidRow(
                  box(
                    title = "Simulation-Based Power Analysis for ROC curves",
                    status = "info",
                    solidHeader = TRUE,
                    width = 12,
                    p("In the current Shiny App, you can conduct a simulation-based power analyses for Receiver Operating Characteristic (ROC) curve/Area Under the Curve (AUC) analyses for null-hypothesis significance testing (NHST), Minimum-effects testing (MET), and equivalence testing (ET;", a("click here",href = "https://doi.org/10.1177/25152459241240722", target = "_blank")," for more information on the different hypothesis tests). The idea behind simulation-based power analyses is simple:"),
                    tags$ul(
                      tags$li("First, a 1000 ROC datasets (can be adjusted for more precise estimates) need to be simulated based on the parameters of interest such as sample size, effect size (i.e., AUC difference), alpha level, and study parameters (e.g., amount of studied and new items)"),
                      tags$li("Second, each dataset will be analyzed in the way the researchers intend to analyze the data they will eventually collect"),
                      tags$li("Third, statistical power for the different tests can be calculated. For single ROC curves this is by:",
                              tags$ul(
                                tags$li(strong("NHST"),": proportion of results of which 95% CI does not include AUC of .5 (or 50%)"),
                                tags$li(strong("MET"), ": proportion of results of which 95% CI is greater than the smallest effect size of interest (SESOI)"),
                                tags$li(strong("ET"), ": proportion of results of which the 90%CI of the AUC  are within the equivalence bounds which are set by the SESOI"))),
                      tags$li("For multiple ROC curves (AUC difference) this is by:",
                              tags$ul(
                                tags$li(strong("NHST"),": proportion of results of which the 95% confidence (CI) of the AUC difference it does not include 0"),
                                tags$li(strong("MET"), ": proportion of results of which the 95%CI of the AUC difference does not include the SESOI"),
                                tags$li(strong("ET"), ": proportion of results of which the 90%CI of the AUC difference are within the equivalence bounds which are set by the SESOI")))),
                    p("To conduct the simulation-based power analysis for AUC differences, the following steps need to be taken:"),
                    tags$ul(
                      tags$li("1: Decide how to estimate the AUCs:",
                              tags$ul(
                                tags$li("a: estimate simplest AUCs for ROC data with equal variances and a mean noise of 0 leading to a curved ROC curve (see tab 1 - Estimate the AUC)"),
                                tags$li("b: estimate AUCs for ROC data with unequal variances and varying mean noise which allows for creating various shapes of ROC curves (see tab 5 - Estimate the AUC - Unequal Variances)",
                                        tags$ul(
                                          tags$li("AUCs are estimated using a sample of 10,000 participants to get accurate AUCs and AUC difference estimates"),
                                          tags$li("The means and standard deviations for signal and noise provided in Step 1 or 5 corresponding to the estimated AUCs are transferred to the next tabs (tab 1 to tabs 2, 3, & 4, and tab 5 to tabs 6, 7, & 8. For the single ROC curve power simulations the means and sds of the first group are transferred.")))),
                              tags$li("2: Decide whether the data will be unpaired (tab 3 and 7) or paired (tab 4 and 8). Then, provide study parameters such as the SESOI (in terms of AUC difference), sample size, number of studied and new items, and the correlation between variables if data is paired. Some information about the SESOI:",
                                      tags$ul(
                                        tags$li(strong("NHST"), ": the estimated AUC difference can simply be used and the SESOI can be set to 0"),
                                        tags$li(strong("MET"), ": the estimated AUC difference needs to be increased slightly in relation to the SESOI because if they are they same the statistical power will be the type 1 error rate"),
                                        tags$li(strong("ET"), ": the estimated AUC differences are typically set to 0. You can also indicate that there will be smaller AUC differences than the SESOI to see how much statistical power you have to find equivalence even if a small but negligible effect exists")))),
                      tags$li("3: Indicate the amount of simulations and click 'Run Simulations'. More simulations might lead to longer processing time. A table will be provided with the statistical power for each test and information on which information needs to be provided in the section on power analyses in the manscript to make the power analysis reproducible.",
                              tags$ul(
                                tags$li("Unequal variance power analyses may take longer to present results because bootstrapping occurs. Normally, with a 1000 simulations it should take around 5-10 seconds before results appear. If bootstrapping is applied the waiting time can be slightly longer."),
                                tags$li("For simulation-based power analyses for differences between partial AUCs (pAUC), you are able to estimate the pAUCs to extract the necessary information (i.e., means and sd of the signal and noise distributions). However, please use the", a("R script",href = "https://osf.io/h2kvj/", target = "_blank")," and run the simulation locally. That is because to examine pAUC differences, bootstrapping is necessary and the power analyes can take up to 1 hour to run for 1,000 simulations.")
                              ))),
                  )
                )
              )
      ),
      # First Tab: Paired ROC Simulation
      tabItem(tabName = "estimate_auc",
              fluidPage(
                titlePanel("Estimate the AUC"),
                sidebarLayout(
                  sidebarPanel(
                    fluidRow(
                      # Group 1 Variables
                      box(
                        title = "Group 1 Variables", status = "primary", solidHeader = TRUE, width = 12,
                        sliderInput("mean_signal_g1", "Mean Signal Group 1:", min = 0, max = 4, value = 1, step = 0.01)
                      )
                    ),

                    fluidRow(
                      # Group 2 Variables
                      box(
                        title = "Group 2 Variables", status = "primary", solidHeader = TRUE, width = 12,
                        sliderInput("mean_signal_g2", "Mean Signal Group 2:", min = 0, max = 4, value = 0.5, step = 0.01)
                      )
                    ),

                    # Shared Variables
                    fluidRow(
                      box(
                        title = "Study Parameters", status = "primary", solidHeader = TRUE, width = 12,
                        sliderInput("n_studied", "Number of Studied Items:", min = 1, max = 20, value = 5),
                        sliderInput("n_new", "Number of New Items:", min = 1, max = 20, value = 5)
                      )
                    )
                  ),
                  mainPanel(
                    plotOutput("roc_plot_g1"),
                    plotOutput("roc_plot_g2")
                  )
                )
              )
      )
      ,
      # Second Tab: Single ROC curve power Simulation
      tabItem(tabName = "single_roc_ev",
              fluidPage(
                titlePanel("Single ROC Power Simulation"),
                sidebarLayout(
                  sidebarPanel(
                    fluidRow(
                      # Group 1 Variables
                      box(
                        title = "Group 1 Variables", status = "primary", solidHeader = TRUE, width = 12,
                        sliderInput("mean_signal_single", "Mean Signal Group 1:", min = 0, max = 4, value = 0.8, step = 0.01),
                        sliderInput("n_g1_single", "Number of Participants:", min = 10, max = 500, value = 100)
                      )
                    ),

                    # Shared Parameters
                    fluidRow(
                      box(
                        title = "Study Parameters", status = "primary", solidHeader = TRUE, width = 12,
                        sliderInput("SESOI_single", "SESOI in terms of AUC:", min = 0, max = 1, value = 0.50),
                        sliderInput("n_studied_single", "Number of Studied Items:", min = 1, max = 20, value = 5),
                        sliderInput("n_new_single", "Number of New Items:", min = 1, max = 20, value = 5),
                        numericInput("n_simulations_single", "Number of Simulations:", value = 1000, min = 10, max = 10000, step = 100),
                        actionButton("run_sim_single", "Run Simulations")
                      )
                    )
                  ),
                  mainPanel(
                    tableOutput("power_results_single"),
                    tableOutput("power_table_single"),
                    verbatimTextOutput("summary_text_single")
                  )
                )
              )
      ),
      # Third Tab: Unpaired ROC Simulation
      tabItem(tabName = "unpaired_roc",
              fluidPage(
                titlePanel("Unpaired ROC Power Simulation"),
                sidebarLayout(
                  sidebarPanel(
                    fluidRow(
                      # Group 1 Variables
                      box(
                        title = "Group 1 Variables", status = "primary", solidHeader = TRUE, width = 12,
                        sliderInput("mean_signal_g1_up", "Mean Signal Group 1:", min = 0, max = 4, value = 0.8, step = 0.01),
                        sliderInput("n_g1_up", "Number of Participants in Group 1:", min = 10, max = 500, value = 100)
                      )
                    ),

                    fluidRow(
                      # Group 2 Variables
                      box(
                        title = "Group 2 Variables", status = "primary", solidHeader = TRUE, width = 12,
                        sliderInput("mean_signal_g2_up", "Mean Signal Group 2:", min = 0, max = 4, value = 0.7, step = 0.01),
                        sliderInput("n_g2_up", "Number of Participants in Group 2:", min = 10, max = 500, value = 100)
                      )
                    ),

                    # Shared Parameters
                    fluidRow(
                      box(
                        title = "Study Parameters", status = "primary", solidHeader = TRUE, width = 12,
                        sliderInput("SESOI_up", "SESOI in terms of AUC difference:", min = 0, max = 1, value = 0.10),
                        sliderInput("n_studied_up", "Number of Studied Items:", min = 1, max = 20, value = 5),
                        sliderInput("n_new_up", "Number of New Items:", min = 1, max = 20, value = 5),
                        numericInput("n_simulations_up", "Number of Simulations:", value = 1000, min = 10, max = 10000, step = 100),
                        actionButton("run_sim_up", "Run Simulations")
                      )
                    )
                  ),
                  mainPanel(
                    tableOutput("power_results1"),
                    tableOutput("power_table1"),
                    verbatimTextOutput("summary_text1")
                  )
                )
              )
      ),

      # Fourth Tab: Paired ROC Simulation
      tabItem(tabName = "paired_roc",
              fluidPage(
                titlePanel("Paired ROC Power Simulation"),
                sidebarLayout(
                  sidebarPanel(
                    fluidRow(
                      # Group 1 Variables
                      box(
                        title = "Group 1 Variables", status = "primary", solidHeader = TRUE, width = 12,
                        sliderInput("mean_signal_g1_p", "Mean Signal Group 1:", min = 0, max = 4, value = 0.8, step = 0.01)
                      )
                    ),

                    fluidRow(
                      # Group 2 Variables
                      box(
                        title = "Group 2 Variables", status = "primary", solidHeader = TRUE, width = 12,
                        sliderInput("mean_signal_g2_p", "Mean Signal Group 2:", min = 0, max = 4, value = 0.7, step = 0.01)
                      )
                    ),

                    # Shared Parameters
                    fluidRow(
                      box(
                        title = "Study Parameters", status = "primary", solidHeader = TRUE, width = 12,
                        sliderInput("n_g1_p", "Number of Participants:", min = 10, max = 500, value = 100),
                        sliderInput("SESOI_p", "SESOI in terms of AUC difference:", min = 0, max = 1, value = 0.10),
                        sliderInput("n_studied_p", "Number of Studied Items:", min = 1, max = 20, value = 5),
                        sliderInput("n_new_p", "Number of New Items:", min = 1, max = 20, value = 5),
                        sliderInput("rho_p", "Correlation between Groups:", min = 0, max = 1, value = 0.0, step = 0.05),
                        numericInput("n_simulations_p", "Number of Simulations:", value = 1000, min = 10, max = 10000, step = 100),
                        actionButton("run_sim_p", "Run Simulations")
                      )
                    )
                  ),
                  mainPanel(
                    tableOutput("power_results2"),
                    tableOutput("power_table2"),
                    verbatimTextOutput("summary_text2")
                  )
                )
              )
      ),
      # Fifth Tab: Estimate AUC - Unequal Variances
      tabItem(tabName = "estimate_auc_uv",
              fluidPage(
                titlePanel("Estimate the AUC - Unequal Variances"),
                sidebarLayout(
                  sidebarPanel(
                    fluidRow(
                      # Group 1 Variables
                      box(
                        title = "Group 1 Variables", status = "primary", solidHeader = TRUE, width = 12,
                        sliderInput("mean_signal_g1_uv", "Mean Signal Group 1:", min = 0, max = 4, value = 1, step = 0.01),
                        sliderInput("mean_noise_g1_uv", "Mean Noise Group 1:", min = 0, max = 4, value = 0, step = 0.01),
                        sliderInput("sd_signal_g1_uv", "SD Signal Group 1:", min = 0, max = 4, value = 1, step = 0.01),
                        sliderInput("sd_noise_g1_uv", "SD Noise Group 1:", min = 0, max = 4, value = 1, step = 0.01),
                      )
                    ),

                    fluidRow(
                      # Group 2 Variables
                      box(
                        title = "Group 2 Variables", status = "primary", solidHeader = TRUE, width = 12,
                        sliderInput("mean_signal_g2_uv", "Mean Signal Group 2:", min = 0, max = 4, value = .5, step = 0.01),
                        sliderInput("mean_noise_g2_uv", "Mean Noise Group 2:", min = 0, max = 4, value = 0, step = 0.01),
                        sliderInput("sd_signal_g2_uv", "SD Signal Group 2:", min = 0, max = 4, value = 1, step = 0.01),
                        sliderInput("sd_noise_g2_uv", "SD Noise Group 2:", min = 0, max = 4, value = 1, step = 0.01)
                      )
                    ),

                    # Shared Variables
                    fluidRow(
                      box(
                        title = "Study Parameters", status = "primary", solidHeader = TRUE, width = 12,
                        sliderInput("n_studied_uv", "Number of Studied Items:", min = 1, max = 20, value = 5),
                        sliderInput("n_new_uv", "Number of New Items:", min = 1, max = 20, value = 5)
                      )
                    )
                  ),
                  mainPanel(
                    plotOutput("roc_plot_g1_uv"),
                    plotOutput("roc_plot_g2_uv")
                  )
                )
              )
      )
      ,

      # Sixth Tab: Single ROC Simulation - Unequal Variances
      tabItem(tabName = "single_roc_uv",
              fluidPage(
                titlePanel("Single ROC Power Simulation - Unequal Variances"),
                sidebarLayout(
                  sidebarPanel(
                    fluidRow(
                      # Group 1 Variables
                      box(
                        title = "Group 1 Variables", status = "primary", solidHeader = TRUE, width = 12,
                        sliderInput("mean_signal_g1_single_uv", "Mean Signal Group 1:", min = 0, max = 4, value = 1, step = 0.01),
                        sliderInput("mean_noise_g1_single_uv", "Mean Noise Group 1:", min = 0, max = 4, value = 0, step = 0.01),
                        sliderInput("sd_signal_g1_single_uv", "SD Signal Group 1:", min = 0, max = 4, value = 1, step = 0.01),
                        sliderInput("sd_noise_g1_single_uv", "SD Noise Group 1:", min = 0, max = 4, value = 1, step = 0.01),
                        sliderInput("n_g1_single_uv", "Number of Participants:", min = 10, max = 500, value = 100)
                      )
                    ),
                    # Shared Parameters
                    fluidRow(
                      box(
                        title = "Study Parameters", status = "primary", solidHeader = TRUE, width = 12,
                        sliderInput("SESOI_single_uv", "SESOI in terms of AUC difference:", min = 0, max = 1, value = 0.5),
                        sliderInput("n_studied_single_uv", "Number of Studied Items:", min = 1, max = 20, value = 5),
                        sliderInput("n_new_single_uv", "Number of New Items:", min = 1, max = 20, value = 5),
                        numericInput("n_simulations_single_uv", "Number of Simulations:", value = 1000, min = 10, max = 10000, step = 100),
                        actionButton("run_sim_single_uv", "Run Simulations")
                      )
                    )
                  )
                  ,
                  mainPanel(
                    tableOutput("power_results_single_uv"),
                    tableOutput("power_table_single_uv"),
                    verbatimTextOutput("summary_text_single_uv")

                  )
                )
              )
      ),

      # Seventh Tab: Unpaired ROC Simulation - Unequal Variances
      tabItem(tabName = "unpaired_roc_uv",
              fluidPage(
                titlePanel("Unpaired ROC Power Simulation - Unequal Variances"),
                sidebarLayout(
                  sidebarPanel(
                    fluidRow(
                      # Group 1 Variables
                      box(
                        title = "Group 1 Variables", status = "primary", solidHeader = TRUE, width = 12,
                        sliderInput("mean_signal_g1_up_uv", "Mean Signal Group 1:", min = 0, max = 4, value = 1, step = 0.01),
                        sliderInput("mean_noise_g1_up_uv", "Mean Noise Group 1:", min = 0, max = 4, value = 0, step = 0.01),
                        sliderInput("sd_signal_g1_up_uv", "SD Signal Group 1:", min = 0, max = 4, value = 1, step = 0.01),
                        sliderInput("sd_noise_g1_up_uv", "SD Noise Group 1:", min = 0, max = 4, value = 1, step = 0.01),
                        sliderInput("n_g1_up_uv", "Number of Participants in Group 1:", min = 10, max = 500, value = 100)
                      )
                    ),

                    fluidRow(
                      # Group 2 Variables
                      box(
                        title = "Group 2 Variables", status = "primary", solidHeader = TRUE, width = 12,
                        sliderInput("mean_signal_g2_up_uv", "Mean Signal Group 2:", min = 0, max = 4, value = .5, step = 0.01),
                        sliderInput("mean_noise_g2_up_uv", "Mean Noise Group 2:", min = 0, max = 4, value = 0, step = 0.01),
                        sliderInput("sd_signal_g2_up_uv", "SD Signal Group 2:", min = 0, max = 4, value = 1, step = 0.01),
                        sliderInput("sd_noise_g2_up_uv", "SD Noise Group 2:", min = 0, max = 4, value = 1, step = 0.01),
                        sliderInput("n_g2_up_uv", "Number of Participants in Group 2:", min = 10, max = 500, value = 100)
                      )
                    ),

                    # Shared Parameters
                    fluidRow(
                      box(
                        title = "Study Parameters", status = "primary", solidHeader = TRUE, width = 12,
                        sliderInput("SESOI_up_uv", "SESOI in terms of AUC difference:", min = 0, max = 1, value = 0.10),
                        sliderInput("n_studied_up_uv", "Number of Studied Items:", min = 1, max = 20, value = 5),
                        sliderInput("n_new_up_uv", "Number of New Items:", min = 1, max = 20, value = 5),
                        numericInput("n_simulations_up_uv", "Number of Simulations:", value = 1000, min = 10, max = 10000, step = 100),
                        actionButton("run_sim_up_uv", "Run Simulations")
                      )
                    )
                  )
                  ,
                  mainPanel(
                    tableOutput("power_results1_uv"),
                    tableOutput("power_table1_up_uv"),
                    verbatimTextOutput("summary_text_up_uv")

                  )
                )
              )
      ),

      # Eight Tab: Paired ROC Simulation - Unequal Variances
      tabItem(tabName = "paired_roc_uv",
              fluidPage(
                titlePanel("Paired ROC Power Simulation - Unequal Variances"),
                sidebarLayout(
                  sidebarPanel(
                    fluidRow(
                      # Group 1 Variables
                      box(
                        title = "Group 1 Variables", status = "primary", solidHeader = TRUE, width = 12,
                        sliderInput("mean_signal_g1_p_uv", "Mean Signal Group 1 (Equal Variance):", min = 0, max = 4, value = 1, step = 0.01),
                        sliderInput("mean_noise_g1_p_uv", "Mean Noise Group 1:", min = 0, max = 4, value = 0, step = 0.01),
                        sliderInput("sd_signal_g1_p_uv", "SD Signal Group 1:", min = 0, max = 4, value = 1, step = 0.01),
                        sliderInput("sd_noise_g1_p_uv", "SD Noise Group 1:", min = 0, max = 4, value = 1, step = 0.01)
                      )
                    ),

                    fluidRow(
                      # Group 2 Variables
                      box(
                        title = "Group 2 Variables", status = "primary", solidHeader = TRUE, width = 12,
                        sliderInput("mean_signal_g2_p_uv", "Mean Signal Group 2 (Equal Variance):", min = 0, max = 4, value = .5, step = 0.01),
                        sliderInput("mean_noise_g2_p_uv", "Mean Noise Group 2:", min = 0, max = 4, value = 0, step = 0.01),
                        sliderInput("sd_signal_g2_p_uv", "SD Signal Group 2:", min = 0, max = 4, value = 1, step = 0.01),
                        sliderInput("sd_noise_g2_p_uv", "SD Noise Group 2:", min = 0, max = 4, value = 1, step = 0.01)
                      )
                    ),

                    # Shared Parameters
                    fluidRow(
                      box(
                        title = "Study Parameters", status = "primary", solidHeader = TRUE, width = 12,
                        sliderInput("n_g1_p_uv", "Number of Participants:", min = 10, max = 500, value = 100),
                        sliderInput("SESOI_p_uv", "SESOI in terms of AUC difference:", min = 0, max = 1, value = 0.10),
                        sliderInput("n_studied_p_uv", "Number of Studied Items:", min = 1, max = 20, value = 5),
                        sliderInput("n_new_p_uv", "Number of New Items:", min = 1, max = 20, value = 5),
                        sliderInput("rho_p_uv", "Correlation between Groups:", min = 0, max = 1, value = 0.0, step = 0.05),
                        numericInput("n_simulations_p_uv", "Number of Simulations:", value = 1000, min = 10, max = 10000, step = 100),
                        actionButton("run_sim_p_uv", "Run Simulations")
                      )
                    )
                  )
                  ,
                  mainPanel(
                    tableOutput("power_results2_uv"),
                    tableOutput("power_table2_p_uv"),
                    verbatimTextOutput("summary_text_p_uv")
                  )
                )
              )
      ),
      # 9th Tab: Estimate pAUC - (Un+)equal Variances
      tabItem(tabName = "estimate_pauc",
              fluidPage(
                titlePanel("Estimate the pAUC - Equal + Unequal Variances"),
                sidebarLayout(
                  sidebarPanel(
                    fluidRow(
                      # Group 1 Variables
                      box(
                        title = "Group 1 Variables", status = "primary", solidHeader = TRUE, width = 12,
                        sliderInput("mean_signal_g1_pauc", "Mean Signal Group 1:", min = 0, max = 4, value = 1, step = 0.01),
                        sliderInput("mean_noise_g1_pauc", "Mean Noise Group 1:", min = 0, max = 4, value = 0, step = 0.01),
                        sliderInput("sd_signal_g1_pauc", "SD Signal Group 1:", min = 0, max = 4, value = 1, step = 0.01),
                        sliderInput("sd_noise_g1_pauc", "SD Noise Group 1:", min = 0, max = 4, value = 1, step = 0.01),
                      )
                    ),

                    fluidRow(
                      # Group 2 Variables
                      box(
                        title = "Group 2 Variables", status = "primary", solidHeader = TRUE, width = 12,
                        sliderInput("mean_signal_g2_pauc", "Mean Signal Group 2:", min = 0, max = 4, value = .5, step = 0.01),
                        sliderInput("mean_noise_g2_pauc", "Mean Noise Group 2:", min = 0, max = 4, value = 0, step = 0.01),
                        sliderInput("sd_signal_g2_pauc", "SD Signal Group 2:", min = 0, max = 4, value = 1, step = 0.01),
                        sliderInput("sd_noise_g2_pauc", "SD Noise Group 2:", min = 0, max = 4, value = 1, step = 0.01)
                      )
                    ),

                    # Shared Variables
                    fluidRow(
                      box(
                        title = "Study Parameters", status = "primary", solidHeader = TRUE, width = 12,
                        sliderInput("n_studied_pauc", "Number of Studied Items:", min = 1, max = 20, value = 5),
                        sliderInput("n_new_pauc", "Number of New Items:", min = 1, max = 20, value = 5),
                        sliderInput("low_bound", "Lower bound partial AUC:", min = 0, max = 1, value = 1),
                        sliderInput("up_bound", "Upper bound partial AUC:", min = 0, max = 1, value = .83)
                      )
                    )
                  ),
                  mainPanel(
                    plotOutput("roc_plot_g1_pauc"),
                    plotOutput("roc_plot_g2_pauc")
                  )
                )
              )
      )
    )
  )
)

# Define server logic
server <- function(input, output, session) {

  # Observer to update mean_signal_g2 whenever mean_signal_g1 changes
  observe({
    updateSliderInput(session, "mean_signal_single", value = input$mean_signal_g1)
    updateSliderInput(session, "mean_signal_g1_up", value = input$mean_signal_g1)
    updateSliderInput(session, "mean_signal_g2_up", value = input$mean_signal_g2)
    updateSliderInput(session, "mean_signal_g1_p", value = input$mean_signal_g1)
    updateSliderInput(session, "mean_signal_g2_p", value = input$mean_signal_g2)
    updateSliderInput(session, "mean_signal_g1_single_uv", value = input$mean_signal_g1_uv)
    updateSliderInput(session, "mean_noise_g1_single_uv", value = input$mean_noise_g1_uv)
    updateSliderInput(session, "sd_signal_g1_single_uv", value = input$sd_signal_g1_uv)
    updateSliderInput(session, "sd_noise_g1_single_uv", value = input$sd_noise_g1_uv)
    updateSliderInput(session, "mean_signal_g1_up_uv", value = input$mean_signal_g1_uv)
    updateSliderInput(session, "mean_signal_g2_up_uv", value = input$mean_signal_g2_uv)
    updateSliderInput(session, "mean_signal_g1_p_uv", value = input$mean_signal_g1_uv)
    updateSliderInput(session, "mean_signal_g2_p_uv", value = input$mean_signal_g2_uv)
    updateSliderInput(session, "mean_noise_g1_up_uv", value = input$mean_noise_g1_uv)
    updateSliderInput(session, "mean_noise_g2_up_uv", value = input$mean_noise_g2_uv)
    updateSliderInput(session, "mean_noise_g1_p_uv", value = input$mean_noise_g1_uv)
    updateSliderInput(session, "mean_noise_g2_p_uv", value = input$mean_noise_g2_uv)
    updateSliderInput(session, "sd_signal_g1_up_uv", value = input$sd_signal_g1_uv)
    updateSliderInput(session, "sd_signal_g2_up_uv", value = input$sd_signal_g2_uv)
    updateSliderInput(session, "sd_signal_g1_p_uv", value = input$sd_signal_g1_uv)
    updateSliderInput(session, "sd_signal_g2_p_uv", value = input$sd_signal_g2_uv)
    updateSliderInput(session, "sd_noise_g1_up_uv", value = input$sd_noise_g1_uv)
    updateSliderInput(session, "sd_noise_g2_up_uv", value = input$sd_noise_g2_uv)
    updateSliderInput(session, "sd_noise_g1_p_uv", value = input$sd_noise_g1_uv)
    updateSliderInput(session, "sd_noise_g2_p_uv", value = input$sd_noise_g2_uv)
    updateSliderInput(session, "n_studied_single", value = input$n_studied)
    updateSliderInput(session, "n_new_single", value = input$n_new)
    updateSliderInput(session, "n_studied_up", value = input$n_studied)
    updateSliderInput(session, "n_new_up", value = input$n_new)
    updateSliderInput(session, "n_studied_p", value = input$n_studied)
    updateSliderInput(session, "n_new_p", value = input$n_new)
    updateSliderInput(session, "n_studied_single_uv", value = input$n_studied_uv)
    updateSliderInput(session, "n_new_single_uv", value = input$n_new_uv)
    updateSliderInput(session, "n_studied_up_uv", value = input$n_studied_uv)
    updateSliderInput(session, "n_new_up_uv", value = input$n_new_uv)
    updateSliderInput(session, "n_studied_p_uv", value = input$n_studied_uv)
    updateSliderInput(session, "n_new_p_uv", value = input$n_new_uv)


  })

  # Paired ROC simulation
  simulate_paired_roc <- reactive({
    set.seed(2794)
    # Get input values
    mean_signal_g1 <- input$mean_signal_g1
    mean_signal_g2 <- input$mean_signal_g2
    n_studied <- input$n_studied
    n_new <- input$n_new

    #   # Sample size to get perfect AUC estimate. Standard deviations for signal and mean and standard deviation noise
    n_g1 <- 10000
    sd_signal_g1 <- 1
    sd_signal_g2 <- 1
    sd_noise_g1 <- 1
    sd_noise_g2 <- 1
    mean_noise_g1 <- 0
    mean_noise_g2 <- 0
    rho <- 0

    # Covariance matrix for correlated signal and noise
    cov_matrix_signal <- matrix(c(sd_signal_g1^2, rho * sd_signal_g1 * sd_signal_g2,
                                  rho * sd_signal_g1 * sd_signal_g2, sd_signal_g2^2), nrow = 2)
    cov_matrix_noise <- matrix(c(sd_noise_g1^2, rho * sd_noise_g1 * sd_noise_g2,
                                 rho * sd_noise_g1 * sd_noise_g2, sd_noise_g2^2), nrow = 2)

    # Generate correlated signal and noise for Group 1 and Group 2
    signal_data <- mvrnorm(n_g1 * n_studied, mu = c(mean_signal_g1, mean_signal_g2), Sigma = cov_matrix_signal)
    noise_data <- mvrnorm(n_g1 * n_new, mu = c(mean_noise_g1, mean_noise_g2), Sigma = cov_matrix_noise)

    # Combine signal and noise for both groups
    ratings_g1 <- c(signal_data[, 1], noise_data[, 1])
    ratings_g2 <- c(signal_data[, 2], noise_data[, 2])

    labels <- c(rep(1, n_g1 * n_studied), rep(0, n_g1 * n_new))

    # Define 6-point scale cutoffs (based on quantiles for balance)
    cutoffs_g1 <- quantile(ratings_g1, probs = seq(0, 1, length.out = 7))
    cutoffs_g2 <- quantile(ratings_g2, probs = seq(0, 1, length.out = 7))

    # Assign 6-point ratings for both groups
    ratings_g1 <- cut(ratings_g1, breaks = cutoffs_g1, labels = 1:6, include.lowest = TRUE)
    ratings_g2 <- cut(ratings_g2, breaks = cutoffs_g2, labels = 1:6, include.lowest = TRUE)

    # Convert to numeric for ROC calculations
    ratings_g1 <- as.numeric(ratings_g1)
    ratings_g2 <- as.numeric(ratings_g2)

    # Calculate paired ROC using pROC
    roc_g1 <- roc(labels, ratings_g1, direction = "<")
    roc_g2 <- roc(labels, ratings_g2, direction = "<")

    return(list(roc_g1 = roc_g1, roc_g2 = roc_g2, ratings_g1 = ratings_g1, ratings_g2 = ratings_g2, labels = labels))
  })

  output$roc_plot_g1 <- renderPlot({
    roc_data <- simulate_paired_roc()
    if (!is.null(roc_data)) {
      par(pty="s")
      plot(roc_data$roc_g1, col = "blue", main = "ROC Curve - Group 1", legacy.axes=TRUE, xlab="False Positive Rate",
           ylab="True Postive Rate",print.auc=T)
    }
  })

  output$roc_plot_g2 <- renderPlot({
    roc_data <- simulate_paired_roc()
    if (!is.null(roc_data)) {
      par(pty="s")
      plot(roc_data$roc_g2, col = "red", main = "ROC Curve - Group 2", legacy.axes=TRUE, xlab="False Positive Rate",
           ylab="True Postive Rate", print.auc=T)
    }
  })

  # Single  ROC simulation - Equal variances
  single_roc_ev <- eventReactive(input$run_sim_single,{
    set.seed(2794)
    # Get input values
    mean_signal_g1 <- input$mean_signal_single
    n_g1 <- input$n_g1_single
    n_studied <- input$n_studied_single
    n_new <- input$n_new_single
    n_simulations <- input$n_simulations_single
    SESOI <- input$SESOI_single

    # Signal and noise parameters for both groups
    n_sig_g1 <- n_g1 * n_studied
    n_noise_g1 <- n_g1 * n_new


    sd_signal_g1 <- 1
    sd_noise_g1 <- 1
    mean_noise_g1 <- 0


    n_sig_g1   <- n_g1 * n_studied
    n_noise_g1 <- n_g1 * n_new

    # Function to simulate one dataset for two groups and calculate AUCs
    simulate_roc <- function() {

      # Generate signal and noise for Group 1
      signal_g1 <- rnorm(n_sig_g1, mean_signal_g1, sd_signal_g1)
      noise_g1 <- rnorm(n_noise_g1, mean_noise_g1, sd_noise_g1)

      # Combine signal and noise for both groups
      ratings_g1 <- c(signal_g1, noise_g1)
      labels_g1 <- c(rep(1, n_sig_g1), rep(0, n_noise_g1))

      # Define 6-point scale cutoffs (based on quantiles for balance)
      cutoffs_g1 <- quantile(ratings_g1, probs = seq(0, 1, length.out = 7))

      # Assign ratings on the 6-point scale for both groups
      ratings_g1 <- cut(ratings_g1, breaks = cutoffs_g1, labels = 1:6, include.lowest = TRUE)

      # Calculate ROC for both groups
      roc_g1 <- roc(labels_g1, as.numeric(ratings_g1))

      # Return the ROC objects
      return(list(roc_g1 = roc_g1))
    }

    # Simulation of  datasets
    roc_g1_list <- vector("list", n_simulations)

    # Simulate 1000 datasets and store ROC results
    for (i in 1:n_simulations) {
      rocs <- simulate_roc()
      roc_g1_list[[i]] <- rocs$roc_g1
    }

    # Function to collect AUCs, calculate CIs, and perform roc.test
    perform_roc_tests <- function(roc_g1_list) {
      n_simulations <- length(roc_g1_list)
      auc_control <- numeric(n_simulations)
      conf_lowcontrol95 <- numeric(n_simulations)
      conf_highcontrol95 <- numeric(n_simulations)
      conf_lowcontrol90 <- numeric(n_simulations)
      conf_highcontrol90 <- numeric(n_simulations)

      # Perform roc.test and calculate CIs for each dataset
      for (i in 1:n_simulations) {

        # Confidence intervals for each group
        CI_control95 <- ci(roc_g1_list[[i]], conf.level = 0.95)
        CI_control90 <- ci(roc_g1_list[[i]], conf.level = 0.90)

        # AUC and confidence interval extraction
        auc_control[i] <- CI_control95[2]
        conf_lowcontrol95[i] <- CI_control95[1]
        conf_highcontrol95[i] <- CI_control95[3]
        conf_lowcontrol90[i] <- CI_control90[1]
        conf_highcontrol90[i] <- CI_control90[3]

      }

      # Return p-values, AUCs, CIs, and differences
      return(list(
        auc_control = auc_control,
        conf_lowcontrol95 = conf_lowcontrol95, conf_highcontrol95 = conf_highcontrol95,
        conf_lowcontrol90 = conf_lowcontrol90, conf_highcontrol90 = conf_highcontrol90

      ))
    }

    # Run roc.test on all 1000 simulations
    results <- perform_roc_tests(roc_g1_list)

    # Power table
    power <- data.frame(
      "NHST" = mean(results$conf_lowcontrol95 > 0.5 | results$conf_highcontrol95 < 0.5, na.rm=T),
      "ET" = mean(results$conf_lowcontrol90 > -SESOI & results$conf_highcontrol90 < SESOI, na.rm=T),
      "MET" = mean(results$conf_lowcontrol95 > SESOI | results$conf_highcontrol95 < -SESOI, na.rm=T))

    # Create a summary text based on the power calculations
    summary_text <- paste(
      "The analysis yielded the following results:\n",
      "1. NHST (Null Hypothesis Significance Testing): ", round(power$NHST * 100, 2), "% of simulations rejected the null hypothesis at the 0.05 level.\n",
      "2. ET (Equivalence Testing): ", round(power$ET * 100, 2), "% of simulations demonstrated equivalence within the specified smallest effect size of interest (SESOI).\n",
      "3. MET (Minimum-Effects Testing): ", round(power$MET * 100, 2), "% of simulations showed significant minimum effects in either direction relative to the SESOI.\n",
      "\n",
      "Please report the following information for the power analysis section: \n",
      "Based on a simulation-based power analysis (Riesthuis et al., 2024), using the following parameters for: \n",
      "1. Group 1: mean signal =", mean_signal_g1,", signal sd =", sd_signal_g1,", mean noise =",mean_noise_g1, ", noise sd =",sd_noise_g1, "n =", n_g1, "\n",
      "2. Study: SESOI =", SESOI, ", n =", n_g1, ", number of studied items =", n_studied, ", number of new items =", n_new, "\n",
      "3. Simulation: number of simulations =", n_simulations, "set.seed = (2794)"
    )

    return(list(power_table = power, summary = summary_text))
  })


  output$power_table_single <- renderTable({
    single_roc_ev()$power_table
  })

  output$summary_text_single <- renderText({
    single_roc_ev()$summary
  })


  # Unpaired  ROC simulation
  unpaired_roc <- eventReactive(input$run_sim_up,{
    set.seed(2794)
    # Get input values
    mean_signal_g1 <- input$mean_signal_g1_up
    mean_signal_g2 <- input$mean_signal_g2_up
    n_g1 <- input$n_g1_up
    n_g2 <- input$n_g2_up
    n_studied <- input$n_studied_up
    n_new <- input$n_new_up
    n_simulations <- input$n_simulations_up
    SESOI <- input$SESOI_up

    # Signal and noise parameters for both groups
    n_sig_g1 <- n_g1 * n_studied
    n_noise_g1 <- n_g1 * n_new
    n_sig_g2 <- n_g2 * n_studied
    n_noise_g2 <- n_g2 * n_new

    sd_signal_g1 <- 1
    sd_noise_g1 <- 1
    sd_signal_g2 <- 1
    sd_noise_g2 <- 1
    mean_noise_g1 <- 0
    mean_noise_g2 <- 0

    # Simulate ROC
    simulate_roc <- function() {
      # Generate signal and noise for Group 1
      signal_g1 <- rnorm(n_sig_g1, mean_signal_g1, sd_signal_g1)
      noise_g1 <- rnorm(n_noise_g1, mean_noise_g1, sd_noise_g1)

      # Generate signal and noise for Group 2
      signal_g2 <- rnorm(n_sig_g2, mean_signal_g2, sd_signal_g2)
      noise_g2 <- rnorm(n_noise_g2, mean_noise_g2, sd_noise_g2)

      # Combine signal and noise
      ratings_g1 <- c(signal_g1, noise_g1)
      ratings_g2 <- c(signal_g2, noise_g2)
      labels_g1 <- c(rep(1, n_sig_g1), rep(0, n_noise_g1))
      labels_g2 <- c(rep(1, n_sig_g2), rep(0, n_noise_g2))

      # Assign 6-point ratings based on quantiles
      cutoffs_g1 <- quantile(ratings_g1, probs = seq(0, 1, length.out = 7))
      cutoffs_g2 <- quantile(ratings_g2, probs = seq(0, 1, length.out = 7))

      ratings_g1 <- cut(ratings_g1, breaks = cutoffs_g1, labels = 1:6, include.lowest = TRUE)
      ratings_g2 <- cut(ratings_g2, breaks = cutoffs_g2, labels = 1:6, include.lowest = TRUE)

      roc_g1 <- roc(labels_g1, as.numeric(ratings_g1))
      roc_g2 <- roc(labels_g2, as.numeric(ratings_g2))

      return(list(roc_g1 = roc_g1, roc_g2 = roc_g2))
    }

    # Simulate ROC for multiple datasets
    roc_g1_list <- vector("list", n_simulations)
    roc_g2_list <- vector("list", n_simulations)

    for (i in 1:n_simulations) {
      rocs <- simulate_roc()
      roc_g1_list[[i]] <- rocs$roc_g1
      roc_g2_list[[i]] <- rocs$roc_g2
    }

    # Function to collect AUCs, calculate CIs, and perform roc.test
    perform_roc_tests <- function(roc_g1_list, roc_g2_list) {
      n_simulations <- length(roc_g1_list)

      p_values <- numeric(n_simulations)
      auc_exp <- numeric(n_simulations)
      auc_control <- numeric(n_simulations)
      conf_lowexp95 <- numeric(n_simulations)
      conf_highexp95 <- numeric(n_simulations)
      conf_lowcontrol95 <- numeric(n_simulations)
      conf_highcontrol95 <- numeric(n_simulations)
      Diff <- numeric(n_simulations)
      Diff_conf_low95 <- numeric(n_simulations)
      Diff_conf_high95 <- numeric(n_simulations)
      Diff_conf_low90 <- numeric(n_simulations)
      Diff_conf_high90 <- numeric(n_simulations)
      d <- numeric(n_simulations)

      # Perform roc.test and calculate CIs for each dataset
      for (i in 1:n_simulations) {
        # Perform roc.test for each simulation
        test_result <- roc.test(roc_g1_list[[i]], roc_g2_list[[i]], paired = FALSE)
        p_values[i] <- test_result$p.value

        # Confidence intervals for each group
        CI_exp95 <- ci(roc_g1_list[[i]], conf.level = 0.95)
        CI_control95 <- ci(roc_g2_list[[i]], conf.level = 0.95)

        # AUC and confidence interval extraction
        auc_exp[i] <- CI_exp95[2]
        auc_control[i] <- CI_control95[2]
        conf_lowexp95[i] <- CI_exp95[1]
        conf_highexp95[i] <- CI_exp95[3]
        conf_lowcontrol95[i] <- CI_control95[1]
        conf_highcontrol95[i] <- CI_control95[3]

        # Difference in AUC
        Diff[i] <- auc_exp[i] - auc_control[i]

        # 95% confidence interval for the difference
        Diff_conf_low95[i] <- Diff[i] - (1.96 * (Diff[i] / test_result$statistic))
        Diff_conf_high95[i] <- Diff[i] + (1.96 * (Diff[i] / test_result$statistic))

        # 90% confidence interval for the difference
        Diff_conf_low90[i] <- Diff[i] - (1.645 * (Diff[i] / test_result$statistic))
        Diff_conf_high90[i] <- Diff[i] + (1.645 * (Diff[i] / test_result$statistic))

        # Store test statistic
        d[i] <- test_result$statistic
      }

      # Return p-values, AUCs, CIs, and differences
      return(list(
        p_values = p_values,
        auc_exp = auc_exp, auc_control = auc_control,
        conf_lowexp95 = conf_lowexp95, conf_highexp95 = conf_highexp95,
        conf_lowcontrol95 = conf_lowcontrol95, conf_highcontrol95 = conf_highcontrol95,
        Diff = Diff,
        Diff_conf_low95 = Diff_conf_low95, Diff_conf_high95 = Diff_conf_high95,
        Diff_conf_low90 = Diff_conf_low90, Diff_conf_high90 = Diff_conf_high90,
        d = d
      ))
    }

    results <- perform_roc_tests(roc_g1_list, roc_g2_list)

    # Power table
    power <- data.frame(
      "NHST" = mean(results$Diff_conf_low95 > 0 | results$Diff_conf_high95 < 0, na.rm=T),
      "ET" = mean(results$Diff_conf_low90 > -SESOI & results$Diff_conf_high90 < SESOI, na.rm = TRUE),
      "MET" = mean(results$Diff_conf_low95 > SESOI | results$Diff_conf_high95 < -SESOI, na.rm = TRUE),
      "AUC_diff" = mean(results$Diff)
    )

    # Create a summary text based on the power calculations
    summary_text <- paste(
      "The analysis yielded the following results:\n",
      "1. NHST (Null Hypothesis Significance Testing): ", round(power$NHST * 100, 2), "% of simulations rejected the null hypothesis at the 0.05 level.\n",
      "2. ET (Equivalence Testing): ", round(power$ET * 100, 2), "% of simulations demonstrated equivalence within the specified smallest effect size of interest (SESOI).\n",
      "3. MET (Minimum-Effects Testing): ", round(power$MET * 100, 2), "% of simulations showed significant minimum effects in either direction relative to the SESOI.\n",
      "4. AUC Difference: The mean difference in area under the ROC curves between groups is ", round(power$AUC_diff, 3), ".\n",
      "\n",
      "Please report the following information for the power analysis section: \n",
      "Based on a simulation-based power analysis (Riesthuis et al., 2024), using the following parameters for: \n",
      "1. Group 1: mean signal =", mean_signal_g1,", signal sd =", sd_signal_g1,", mean noise =",mean_noise_g1, ", noise sd =",sd_noise_g1, "n =", n_g1, "\n",
      "2. Group 2:  mean signal =", mean_signal_g2,", signal sd =", sd_signal_g2,", mean noise =",mean_noise_g2, ", noise sd =",sd_noise_g2, "n =", n_g1,  "\n",
      "3. Study: SESOI =", SESOI, ", n =", n_g1, ", number of studied items =", n_studied, ", number of new items =", n_new, "\n",
      "4. Simulation: number of simulations =", n_simulations, "set.seed = (2794)"
    )

    return(list(power_table = power, summary = summary_text))
  })


  output$power_table1 <- renderTable({
    unpaired_roc()$power_table
  })

  output$summary_text1 <- renderText({
    unpaired_roc()$summary
  })


  # Paired  ROC simulation
  paired_roc <- eventReactive(input$run_sim_p,{
    set.seed(2794)
    # Get input values
    mean_signal_g1 <- input$mean_signal_g1_p
    mean_signal_g2 <- input$mean_signal_g2_p
    n_g1 <- input$n_g1_p
    n_studied <- input$n_studied_p
    n_new <- input$n_new_p
    n_simulations <- input$n_simulations_p
    SESOI <- input$SESOI_p
    rho <- input$rho_p


    # Signal and noise parameters for both groups
    n_sig_g1 <- n_g1 * n_studied
    n_noise_g1 <- n_g1 * n_new
    n_sig_g2 <- n_g1 * n_studied
    n_noise_g2 <- n_g1 * n_new

    sd_signal_g1 <- 1
    sd_noise_g1 <- 1
    sd_signal_g2 <- 1
    sd_noise_g2 <- 1
    mean_noise_g1 <- 0
    mean_noise_g2 <- 0

    # Simulate ROC
    simulate_roc <- function() {
      # Covariance matrix for correlated signal and noise
      cov_matrix_signal <- matrix(c(sd_signal_g1^2, rho * sd_signal_g1 * sd_signal_g2,
                                    rho * sd_signal_g1 * sd_signal_g2, sd_signal_g2^2), nrow = 2)
      cov_matrix_noise <- matrix(c(sd_noise_g1^2, rho * sd_noise_g1 * sd_noise_g2,
                                   rho * sd_noise_g1 * sd_noise_g2, sd_noise_g2^2), nrow = 2)

      # Generate correlated signal and noise for Group 1 and Group 2
      signal_data <- mvrnorm(n_g1*n_studied, mu = c(mean_signal_g1, mean_signal_g2), Sigma = cov_matrix_signal)
      noise_data <- mvrnorm(n_g1*n_new, mu = c(mean_noise_g1, mean_noise_g2), Sigma = cov_matrix_noise)

      # Combine signal and noise for both groups
      ratings_g1 <- c(signal_data[, 1], noise_data[, 1])
      ratings_g2 <- c(signal_data[, 2], noise_data[, 2])

      labels <- c(rep(1, n_g1*n_studied), rep(0, n_g1*n_new))

      # Define 6-point scale cutoffs (based on quantiles for balance)
      cutoffs_g1 <- quantile(ratings_g1, probs = seq(0, 1, length.out = 7))
      cutoffs_g2 <- quantile(ratings_g2, probs = seq(0, 1, length.out = 7))

      # Assign 6-point ratings for both groups
      ratings_g1 <- cut(ratings_g1, breaks = cutoffs_g1, labels = 1:6, include.lowest = TRUE)
      ratings_g2 <- cut(ratings_g2, breaks = cutoffs_g2, labels = 1:6, include.lowest = TRUE)

      # Convert to numeric for ROC calculations
      ratings_g1 <- as.numeric(ratings_g1)
      ratings_g2 <- as.numeric(ratings_g2)

      # Calculate paired ROC using pROC
      roc_g1 <- roc(labels, ratings_g1, direction = "<")
      roc_g2 <- roc(labels, ratings_g2, direction = "<")

      # Return the ROC objects for comparison and ratings
      return(list(roc_g1 = roc_g1, roc_g2 = roc_g2, ratings_g1 = ratings_g1, ratings_g2 = ratings_g2, labels = labels))
    }

    # Simulate ROC for multiple datasets
    roc_g1_list <- vector("list", n_simulations)
    roc_g2_list <- vector("list", n_simulations)

    for (i in 1:n_simulations) {
      rocs <- simulate_roc()
      roc_g1_list[[i]] <- rocs$roc_g1
      roc_g2_list[[i]] <- rocs$roc_g2
    }

    # Function to collect AUCs, calculate CIs, and perform roc.test
    perform_roc_tests <- function(roc_g1_list, roc_g2_list) {
      n_simulations <- length(roc_g1_list)

      p_values <- numeric(n_simulations)
      auc_exp <- numeric(n_simulations)
      auc_control <- numeric(n_simulations)
      conf_lowexp95 <- numeric(n_simulations)
      conf_highexp95 <- numeric(n_simulations)
      conf_lowcontrol95 <- numeric(n_simulations)
      conf_highcontrol95 <- numeric(n_simulations)
      Diff <- numeric(n_simulations)
      Diff_conf_low95 <- numeric(n_simulations)
      Diff_conf_high95 <- numeric(n_simulations)
      Diff_conf_low90 <- numeric(n_simulations)
      Diff_conf_high90 <- numeric(n_simulations)
      d <- numeric(n_simulations)

      # Perform roc.test and calculate CIs for each dataset
      for (i in 1:n_simulations) {
        # Perform roc.test for each simulation
        test_result <- roc.test(roc_g1_list[[i]], roc_g2_list[[i]], paired = T)
        p_values[i] <- test_result$p.value

        # Confidence intervals for each group
        CI_exp95 <- ci(roc_g1_list[[i]], conf.level = 0.95)
        CI_control95 <- ci(roc_g2_list[[i]], conf.level = 0.95)

        # AUC and confidence interval extraction
        auc_exp[i] <- CI_exp95[2]
        auc_control[i] <- CI_control95[2]
        conf_lowexp95[i] <- CI_exp95[1]
        conf_highexp95[i] <- CI_exp95[3]
        conf_lowcontrol95[i] <- CI_control95[1]
        conf_highcontrol95[i] <- CI_control95[3]

        # Difference in AUC
        Diff[i] <- auc_exp[i] - auc_control[i]

        # 95% confidence interval for the difference
        Diff_conf_low95[i] <- Diff[i] - (1.96 * (Diff[i] / test_result$statistic))
        Diff_conf_high95[i] <- Diff[i] + (1.96 * (Diff[i] / test_result$statistic))

        # 90% confidence interval for the difference
        Diff_conf_low90[i] <- Diff[i] - (1.645 * (Diff[i] / test_result$statistic))
        Diff_conf_high90[i] <- Diff[i] + (1.645 * (Diff[i] / test_result$statistic))

        # Store test statistic
        d[i] <- test_result$statistic
      }

      # Return p-values, AUCs, CIs, and differences
      return(list(
        p_values = p_values,
        auc_exp = auc_exp, auc_control = auc_control,
        conf_lowexp95 = conf_lowexp95, conf_highexp95 = conf_highexp95,
        conf_lowcontrol95 = conf_lowcontrol95, conf_highcontrol95 = conf_highcontrol95,
        Diff = Diff,
        Diff_conf_low95 = Diff_conf_low95, Diff_conf_high95 = Diff_conf_high95,
        Diff_conf_low90 = Diff_conf_low90, Diff_conf_high90 = Diff_conf_high90,
        d = d
      ))
    }

    results <- perform_roc_tests(roc_g1_list, roc_g2_list)

    # Power table
    power <- data.frame(
      "NHST" = mean(results$Diff_conf_low95 > 0 | results$Diff_conf_high95 < 0, na.rm=T),
      "ET" = mean(results$Diff_conf_low90 > -SESOI & results$Diff_conf_high90 < SESOI, na.rm = TRUE),
      "MET" = mean(results$Diff_conf_low95 > SESOI | results$Diff_conf_high95 < -SESOI, na.rm = TRUE),
      "AUC_diff" = mean(results$Diff)
    )

    # Create a summary text based on the power calculations
    summary_text <- paste(
      "The analysis yielded the following results:\n",
      "1. NHST (Null Hypothesis Significance Testing): ", round(power$NHST * 100, 2), "% of simulations rejected the null hypothesis at the 0.05 level.\n",
      "2. ET (Equivalence Testing): ", round(power$ET * 100, 2), "% of simulations demonstrated equivalence within the specified smallest effect size of interest (SESOI).\n",
      "3. MET (Minimum-Effects Testing): ", round(power$MET * 100, 2), "% of simulations showed significant minimum effects in either direction relative to the SESOI.\n",
      "4. AUC Difference: The mean difference in area under the ROC curves between groups is ", round(power$AUC_diff, 3), ".\n",
      "\n",
      "Please report the following information for the power analysis section: \n",
      "Based on a simulation-based power analysis (Riesthuis et al., 2024), using the following parameters for: \n",
      "1. Group 1: mean signal =", mean_signal_g1,", signal sd =", sd_signal_g1,", mean noise =",mean_noise_g1, ", noise sd =",sd_noise_g1, "\n",
      "2. Group 2:  mean signal =", mean_signal_g2,", signal sd =", sd_signal_g2,", mean noise =",mean_noise_g2, ", noise sd =",sd_noise_g2, "\n",
      "3. Study: SESOI =", SESOI, ", n =", n_g1, ", number of studied items =", n_studied, ", number of new items =", n_new, ", correlation =", rho, "\n",
      "4. Simulation: number of simulations =", n_simulations, "set.seed = (2794)"
    )

    return(list(power_table = power, summary = summary_text))
  })


  output$power_table2 <- renderTable({
    paired_roc()$power_table
  })

  output$summary_text2 <- renderText({
    paired_roc()$summary
  })

  # Estimate Unequal Variance ROC Curves
  simulate_paired_roc_uv <- reactive({
    set.seed(2794)
    # Get input values
    mean_signal_g1 <- input$mean_signal_g1_uv
    mean_signal_g2 <- input$mean_signal_g2_uv
    mean_noise_g1 <- input$mean_noise_g1_uv
    mean_noise_g2 <- input$mean_noise_g2_uv
    sd_signal_g1 <- input$sd_signal_g1_uv
    sd_signal_g2 <- input$sd_signal_g2_uv
    sd_noise_g1 <- input$sd_noise_g1_uv
    sd_noise_g2 <- input$sd_noise_g2_uv
    n_studied <- input$n_studied_uv
    n_new <- input$n_new_uv

    # Sample size to get perfect AUC estimate
    n_g1 <- 10000

    # Correlation
    rho <- .0

    # Covariance matrix for correlated signal and noise
    cov_matrix_signal <- matrix(c(sd_signal_g1^2, rho * sd_signal_g1 * sd_signal_g2,
                                  rho * sd_signal_g1 * sd_signal_g2, sd_signal_g2^2), nrow = 2)
    cov_matrix_noise <- matrix(c(sd_noise_g1^2, rho * sd_noise_g1 * sd_noise_g2,
                                 rho * sd_noise_g1 * sd_noise_g2, sd_noise_g2^2), nrow = 2)

    # Generate correlated signal and noise for Group 1 and Group 2
    signal_data <- mvrnorm(n_g1 * n_studied, mu = c(mean_signal_g1, mean_signal_g2), Sigma = cov_matrix_signal)
    noise_data <- mvrnorm(n_g1 * n_new, mu = c(mean_noise_g1, mean_noise_g2), Sigma = cov_matrix_noise)

    # Combine signal and noise for both groups
    ratings_g1 <- c(signal_data[, 1], noise_data[, 1])
    ratings_g2 <- c(signal_data[, 2], noise_data[, 2])

    labels <- c(rep(1, n_g1 * n_studied), rep(0, n_g1 * n_new))

    # Define 6-point scale cutoffs (based on quantiles for balance)
    cutoffs_g1 <- quantile(ratings_g1, probs = seq(0, 1, length.out = 7))
    cutoffs_g2 <- quantile(ratings_g2, probs = seq(0, 1, length.out = 7))

    # Assign 6-point ratings for both groups
    ratings_g1 <- cut(ratings_g1, breaks = cutoffs_g1, labels = 1:6, include.lowest = TRUE)
    ratings_g2 <- cut(ratings_g2, breaks = cutoffs_g2, labels = 1:6, include.lowest = TRUE)

    # Convert to numeric for ROC calculations
    ratings_g1 <- as.numeric(ratings_g1)
    ratings_g2 <- as.numeric(ratings_g2)

    # Calculate paired ROC using pROC
    roc_g1 <- roc(labels, ratings_g1, direction = "<")
    roc_g2 <- roc(labels, ratings_g2, direction = "<")

    return(list(roc_g1 = roc_g1, roc_g2 = roc_g2, ratings_g1 = ratings_g1, ratings_g2 = ratings_g2, labels = labels))
  })

  output$roc_plot_g1_uv <- renderPlot({
    roc_data <- simulate_paired_roc_uv()
    if (!is.null(roc_data)) {
      par(pty="s")
      plot(roc_data$roc_g1, col = "blue", main = "ROC Curve - Group 1",legacy.axes=TRUE, xlab="False Positive Rate",
           ylab="True Postive Rate", print.auc=T)
    }
  })

  output$roc_plot_g2_uv <- renderPlot({
    roc_data <- simulate_paired_roc_uv()
    if (!is.null(roc_data)) {
      par(pty="s")
      plot(roc_data$roc_g2, col = "red", main = "ROC Curve - Group 2",legacy.axes=TRUE, xlab="False Positive Rate",
           ylab="True Postive Rate", print.auc=T)
    }
  })

  # Single  ROC simulation - Equal variances
  single_roc_uv <- eventReactive(input$run_sim_single_uv,{
    set.seed(2794)
    # Get input values
    mean_signal_g1 <- input$mean_signal_g1_single_uv
    n_g1 <- input$n_g1_single_uv
    n_studied <- input$n_studied_single_uv
    n_new <- input$n_new_single_uv
    n_simulations <- input$n_simulations_single_uv
    SESOI <- input$SESOI_single_uv
    sd_signal_g1 <- input$sd_signal_g1_single_uv
    sd_noise_g1 <- input$sd_noise_g1_single_uv
    mean_noise_g1 <- input$mean_noise_g1_single_uv

    # Signal and noise parameters for both groups
    n_sig_g1 <- n_g1 * n_studied
    n_noise_g1 <- n_g1 * n_new

    # Function to simulate one dataset for two groups and calculate AUCs
    simulate_roc <- function() {

      # Generate signal and noise for Group 1
      signal_g1 <- rnorm(n_sig_g1, mean_signal_g1, sd_signal_g1)
      noise_g1 <- rnorm(n_noise_g1, mean_noise_g1, sd_noise_g1)

      # Combine signal and noise for both groups
      ratings_g1 <- c(signal_g1, noise_g1)
      labels_g1 <- c(rep(1, n_sig_g1), rep(0, n_noise_g1))

      # Define 6-point scale cutoffs (based on quantiles for balance)
      cutoffs_g1 <- quantile(ratings_g1, probs = seq(0, 1, length.out = 7))

      # Assign ratings on the 6-point scale for both groups
      ratings_g1 <- cut(ratings_g1, breaks = cutoffs_g1, labels = 1:6, include.lowest = TRUE)

      # Calculate ROC for both groups
      roc_g1 <- roc(labels_g1, as.numeric(ratings_g1))

      # Return the ROC objects
      return(list(roc_g1 = roc_g1))
    }

    # Simulation of  datasets
    roc_g1_list <- vector("list", n_simulations)

    # Simulate 1000 datasets and store ROC results
    for (i in 1:n_simulations) {
      rocs <- simulate_roc()
      roc_g1_list[[i]] <- rocs$roc_g1
    }

    # Function to collect AUCs, calculate CIs, and perform roc.test
    perform_roc_tests <- function(roc_g1_list) {
      n_simulations <- length(roc_g1_list)
      auc_control <- numeric(n_simulations)
      conf_lowcontrol95 <- numeric(n_simulations)
      conf_highcontrol95 <- numeric(n_simulations)
      conf_lowcontrol90 <- numeric(n_simulations)
      conf_highcontrol90 <- numeric(n_simulations)

      # Perform roc.test and calculate CIs for each dataset
      for (i in 1:n_simulations) {

        # Confidence intervals for each group
        CI_control95 <- ci(roc_g1_list[[i]], conf.level = 0.95)
        CI_control90 <- ci(roc_g1_list[[i]], conf.level = 0.90)

        # AUC and confidence interval extraction
        auc_control[i] <- CI_control95[2]
        conf_lowcontrol95[i] <- CI_control95[1]
        conf_highcontrol95[i] <- CI_control95[3]
        conf_lowcontrol90[i] <- CI_control90[1]
        conf_highcontrol90[i] <- CI_control90[3]

      }

      # Return p-values, AUCs, CIs, and differences
      return(list(
        auc_control = auc_control,
        conf_lowcontrol95 = conf_lowcontrol95, conf_highcontrol95 = conf_highcontrol95,
        conf_lowcontrol90 = conf_lowcontrol90, conf_highcontrol90 = conf_highcontrol90

      ))
    }

    # Run roc.test on all 1000 simulations
    results <- perform_roc_tests(roc_g1_list)

    # Power table
    power <- data.frame(
      "NHST" = mean(results$conf_lowcontrol95 > 0.5 | results$conf_highcontrol95 < 0.5, na.rm=T),
      "ET" = mean(results$conf_lowcontrol90 > -SESOI & results$conf_highcontrol90 < SESOI, na.rm=T),
      "MET" = mean(results$conf_lowcontrol95 > SESOI | results$conf_highcontrol95 < - SESOI, na.rm=T))

    # Create a summary text based on the power calculations
    summary_text <- paste(
      "The analysis yielded the following results:\n",
      "1. NHST (Null Hypothesis Significance Testing): ", round(power$NHST * 100, 2), "% of simulations rejected the null hypothesis at the 0.05 level.\n",
      "2. ET (Equivalence Testing): ", round(power$ET * 100, 2), "% of simulations demonstrated equivalence within the specified smallest effect size of interest (SESOI).\n",
      "3. MET (Minimum-Effects Testing): ", round(power$MET * 100, 2), "% of simulations showed significant minimum effects in either direction relative to the SESOI.\n",
      "\n",
      "Please report the following information for the power analysis section: \n",
      "Based on a simulation-based power analysis (Riesthuis et al., 2024), using the following parameters for: \n",
      "1. Group 1: mean signal =", mean_signal_g1,", signal sd =", sd_signal_g1,", mean noise =",mean_noise_g1, ", noise sd =",sd_noise_g1, "n =", n_g1, "\n",
      "2. Study: SESOI =", SESOI, ", n =", n_g1, ", number of studied items =", n_studied, ", number of new items =", n_new, "\n",
      "3. Simulation: number of simulations =", n_simulations, "set.seed = (2794)"
    )

    return(list(power_table = power, summary = summary_text))
  })


  output$power_table_single_uv <- renderTable({
    single_roc_uv()$power_table
  })

  output$summary_text_single_uv <- renderText({
    single_roc_uv()$summary
  })


  # Unpaired  ROC simulation
  unpaired_roc_uv <- eventReactive(input$run_sim_up_uv,{
    set.seed(2794)
    # Get input values
    mean_signal_g1 <- input$mean_signal_g1_up_uv
    mean_signal_g2 <- input$mean_signal_g2_up_uv
    mean_noise_g1 <- input$mean_noise_g1_up_uv
    mean_noise_g2 <- input$mean_noise_g2_up_uv
    sd_signal_g1 <- input$sd_signal_g1_up_uv
    sd_signal_g2 <- input$sd_signal_g2_up_uv
    sd_noise_g1 <- input$sd_noise_g1_up_uv
    sd_noise_g2 <- input$sd_noise_g2_up_uv
    n_g1 <- input$n_g1_up_uv
    n_g2 <- input$n_g2_up_uv
    n_studied <- input$n_studied_up_uv
    n_new <- input$n_new_up_uv
    n_simulations <- input$n_simulations_up_uv
    SESOI <- input$SESOI_up_uv

    # Signal and noise parameters for both groups
    n_sig_g1 <- n_g1 * n_studied
    n_noise_g1 <- n_g1 * n_new
    n_sig_g2 <- n_g2 * n_studied
    n_noise_g2 <- n_g2 * n_new

    # Simulate ROC
    simulate_roc <- function() {
      # Generate signal and noise for Group 1
      signal_g1 <- rnorm(n_sig_g1, mean_signal_g1, sd_signal_g1)
      noise_g1 <- rnorm(n_noise_g1, mean_noise_g1, sd_noise_g1)

      # Generate signal and noise for Group 2
      signal_g2 <- rnorm(n_sig_g2, mean_signal_g2, sd_signal_g2)
      noise_g2 <- rnorm(n_noise_g2, mean_noise_g2, sd_noise_g2)

      # Combine signal and noise
      ratings_g1 <- c(signal_g1, noise_g1)
      ratings_g2 <- c(signal_g2, noise_g2)
      labels_g1 <- c(rep(1, n_sig_g1), rep(0, n_noise_g1))
      labels_g2 <- c(rep(1, n_sig_g2), rep(0, n_noise_g2))

      # Assign 6-point ratings based on quantiles
      cutoffs_g1 <- quantile(ratings_g1, probs = seq(0, 1, length.out = 7))
      cutoffs_g2 <- quantile(ratings_g2, probs = seq(0, 1, length.out = 7))

      ratings_g1 <- cut(ratings_g1, breaks = cutoffs_g1, labels = 1:6, include.lowest = TRUE)
      ratings_g2 <- cut(ratings_g2, breaks = cutoffs_g2, labels = 1:6, include.lowest = TRUE)

      roc_g1 <- roc(labels_g1, as.numeric(ratings_g1))
      roc_g2 <- roc(labels_g2, as.numeric(ratings_g2))

      return(list(roc_g1 = roc_g1, roc_g2 = roc_g2))
    }

    # Simulate ROC for multiple datasets
    roc_g1_list <- vector("list", n_simulations)
    roc_g2_list <- vector("list", n_simulations)

    for (i in 1:n_simulations) {
      rocs <- simulate_roc()
      roc_g1_list[[i]] <- rocs$roc_g1
      roc_g2_list[[i]] <- rocs$roc_g2
    }

    # Function to collect AUCs, calculate CIs, and perform roc.test
    perform_roc_tests <- function(roc_g1_list, roc_g2_list) {
      n_simulations <- length(roc_g1_list)

      p_values <- numeric(n_simulations)
      auc_exp <- numeric(n_simulations)
      auc_control <- numeric(n_simulations)
      conf_lowexp95 <- numeric(n_simulations)
      conf_highexp95 <- numeric(n_simulations)
      conf_lowcontrol95 <- numeric(n_simulations)
      conf_highcontrol95 <- numeric(n_simulations)
      Diff <- numeric(n_simulations)
      Diff_conf_low95 <- numeric(n_simulations)
      Diff_conf_high95 <- numeric(n_simulations)
      Diff_conf_low90 <- numeric(n_simulations)
      Diff_conf_high90 <- numeric(n_simulations)
      d <- numeric(n_simulations)

      # Perform roc.test and calculate CIs for each dataset
      for (i in 1:n_simulations) {
        # Perform roc.test for each simulation
        test_result <- roc.test(roc_g1_list[[i]], roc_g2_list[[i]], paired = FALSE)
        p_values[i] <- test_result$p.value

        # Confidence intervals for each group
        CI_exp95 <- ci(roc_g1_list[[i]], conf.level = 0.95)
        CI_control95 <- ci(roc_g2_list[[i]], conf.level = 0.95)

        # AUC and confidence interval extraction
        auc_exp[i] <- CI_exp95[2]
        auc_control[i] <- CI_control95[2]
        conf_lowexp95[i] <- CI_exp95[1]
        conf_highexp95[i] <- CI_exp95[3]
        conf_lowcontrol95[i] <- CI_control95[1]
        conf_highcontrol95[i] <- CI_control95[3]

        # Difference in AUC
        Diff[i] <- auc_exp[i] - auc_control[i]

        # 95% confidence interval for the difference
        Diff_conf_low95[i] <- Diff[i] - (1.96 * (Diff[i] / test_result$statistic))
        Diff_conf_high95[i] <- Diff[i] + (1.96 * (Diff[i] / test_result$statistic))

        # 90% confidence interval for the difference
        Diff_conf_low90[i] <- Diff[i] - (1.645 * (Diff[i] / test_result$statistic))
        Diff_conf_high90[i] <- Diff[i] + (1.645 * (Diff[i] / test_result$statistic))

        # Store test statistic
        d[i] <- test_result$statistic
      }

      # Return p-values, AUCs, CIs, and differences
      return(list(
        p_values = p_values,
        auc_exp = auc_exp, auc_control = auc_control,
        conf_lowexp95 = conf_lowexp95, conf_highexp95 = conf_highexp95,
        conf_lowcontrol95 = conf_lowcontrol95, conf_highcontrol95 = conf_highcontrol95,
        Diff = Diff,
        Diff_conf_low95 = Diff_conf_low95, Diff_conf_high95 = Diff_conf_high95,
        Diff_conf_low90 = Diff_conf_low90, Diff_conf_high90 = Diff_conf_high90,
        d = d
      ))
    }

    results <- perform_roc_tests(roc_g1_list, roc_g2_list)

    # Power table
    power <- data.frame(
      "NHST" = mean(results$Diff_conf_low95 > 0 | results$Diff_conf_high95 < 0, na.rm=T),
      "ET" = mean(results$Diff_conf_low90 > -SESOI & results$Diff_conf_high90 < SESOI, na.rm = TRUE),
      "MET" = mean(results$Diff_conf_low95 > SESOI | results$Diff_conf_high95 < -SESOI, na.rm = TRUE),
      "AUC_diff" = mean(results$Diff)
    )

    # Create a summary text based on the power calculations
    summary_text <- paste(
      "The analysis yielded the following results:\n",
      "1. NHST (Null Hypothesis Significance Testing): ", round(power$NHST * 100, 2), "% of simulations rejected the null hypothesis at the 0.05 level.\n",
      "2. ET (Equivalence Testing): ", round(power$ET * 100, 2), "% of simulations demonstrated equivalence within the specified smallest effect size of interest (SESOI).\n",
      "3. MET (Minimum-Effects Testing): ", round(power$MET * 100, 2), "% of simulations showed significant minimum effects in either direction relative to the SESOI.\n",
      "4. AUC Difference: The mean difference in area under the ROC curves between groups is ", round(power$AUC_diff, 3), ".\n",
      "\n",
      "Please report the following information for the power analysis section: \n",
      "Based on a simulation-based power analysis (Riesthuis et al., 2024), using the following parameters for: \n",
      "1. Group 1: mean signal =", mean_signal_g1,", signal sd =", sd_signal_g1,", mean noise =",mean_noise_g1, ", noise sd =",sd_noise_g1, ", n =", n_g1, "\n",
      "2. Group 2:  mean signal =", mean_signal_g2,", signal sd =", sd_signal_g2,", mean noise =",mean_noise_g2, ", noise sd =",sd_noise_g2, ", n =", n_g2, "\n",
      "3. Study: SESOI =", SESOI, ", number of studied items =", n_studied, ", number of new items =", n_new, "\n",
      "4. Simulation: number of simulations =", n_simulations, "set.seed = 2794"
    )

    return(list(power_table = power, summary = summary_text))
  })


  output$power_table1_up_uv <- renderTable({
    unpaired_roc_uv()$power_table
  })

  output$summary_text_up_uv <- renderText({
    unpaired_roc_uv()$summary
  })

  # Paired  ROC simulation
  paired_roc_uv <- eventReactive(input$run_sim_p_uv,{
    set.seed(2794)
    # Get input values
    mean_signal_g1 <- input$mean_signal_g1_p_uv
    mean_signal_g2 <- input$mean_signal_g2_p_uv
    mean_noise_g1 <- input$mean_noise_g1_p_uv
    mean_noise_g2 <- input$mean_noise_g2_p_uv
    sd_signal_g1 <- input$sd_signal_g1_p_uv
    sd_signal_g2 <- input$sd_signal_g2_p_uv
    sd_noise_g1 <- input$sd_noise_g1_p_uv
    sd_noise_g2 <- input$sd_noise_g2_p_uv
    n_g1 <- input$n_g1_p_uv
    n_studied <- input$n_studied_p_uv
    n_new <- input$n_new_p_uv
    n_simulations <- input$n_simulations_p_uv
    rho <- input$rho_p_uv
    SESOI <- input$SESOI_p_uv

    # Signal and noise parameters for both groups
    n_sig_g1 <- n_g1 * n_studied
    n_noise_g1 <- n_g1 * n_new
    n_sig_g2 <- n_g1 * n_studied
    n_noise_g2 <- n_g1 * n_new

    # Simulate ROC
    simulate_roc <- function() {
      # Covariance matrix for correlated signal and noise
      cov_matrix_signal <- matrix(c(sd_signal_g1^2, rho * sd_signal_g1 * sd_signal_g2,
                                    rho * sd_signal_g1 * sd_signal_g2, sd_signal_g2^2), nrow = 2)
      cov_matrix_noise <- matrix(c(sd_noise_g1^2, rho * sd_noise_g1 * sd_noise_g2,
                                   rho * sd_noise_g1 * sd_noise_g2, sd_noise_g2^2), nrow = 2)

      # Generate correlated signal and noise for Group 1 and Group 2
      signal_data <- mvrnorm(n_g1*n_studied, mu = c(mean_signal_g1, mean_signal_g2), Sigma = cov_matrix_signal)
      noise_data <- mvrnorm(n_g1*n_new, mu = c(mean_noise_g1, mean_noise_g2), Sigma = cov_matrix_noise)

      # Combine signal and noise for both groups
      ratings_g1 <- c(signal_data[, 1], noise_data[, 1])
      ratings_g2 <- c(signal_data[, 2], noise_data[, 2])

      labels <- c(rep(1, n_g1*n_studied), rep(0, n_g1*n_new))

      # Define 6-point scale cutoffs (based on quantiles for balance)
      cutoffs_g1 <- quantile(ratings_g1, probs = seq(0, 1, length.out = 7))
      cutoffs_g2 <- quantile(ratings_g2, probs = seq(0, 1, length.out = 7))

      # Assign 6-point ratings for both groups
      ratings_g1 <- cut(ratings_g1, breaks = cutoffs_g1, labels = 1:6, include.lowest = TRUE)
      ratings_g2 <- cut(ratings_g2, breaks = cutoffs_g2, labels = 1:6, include.lowest = TRUE)

      # Convert to numeric for ROC calculations
      ratings_g1 <- as.numeric(ratings_g1)
      ratings_g2 <- as.numeric(ratings_g2)

      # Calculate paired ROC using pROC
      roc_g1 <- roc(labels, ratings_g1, direction = "<")
      roc_g2 <- roc(labels, ratings_g2, direction = "<")

      # Return the ROC objects for comparison and ratings
      return(list(roc_g1 = roc_g1, roc_g2 = roc_g2, ratings_g1 = ratings_g1, ratings_g2 = ratings_g2, labels = labels))
    }

    # Simulate ROC for multiple datasets
    roc_g1_list <- vector("list", n_simulations)
    roc_g2_list <- vector("list", n_simulations)

    for (i in 1:n_simulations) {
      rocs <- simulate_roc()
      roc_g1_list[[i]] <- rocs$roc_g1
      roc_g2_list[[i]] <- rocs$roc_g2
    }

    # Function to collect AUCs, calculate CIs, and perform roc.test
    perform_roc_tests <- function(roc_g1_list, roc_g2_list) {
      n_simulations <- length(roc_g1_list)

      p_values <- numeric(n_simulations)
      auc_exp <- numeric(n_simulations)
      auc_control <- numeric(n_simulations)
      conf_lowexp95 <- numeric(n_simulations)
      conf_highexp95 <- numeric(n_simulations)
      conf_lowcontrol95 <- numeric(n_simulations)
      conf_highcontrol95 <- numeric(n_simulations)
      Diff <- numeric(n_simulations)
      Diff_conf_low95 <- numeric(n_simulations)
      Diff_conf_high95 <- numeric(n_simulations)
      Diff_conf_low90 <- numeric(n_simulations)
      Diff_conf_high90 <- numeric(n_simulations)
      d <- numeric(n_simulations)

      # Perform roc.test and calculate CIs for each dataset
      for (i in 1:n_simulations) {
        # Perform roc.test for each simulation
        test_result <- roc.test(roc_g1_list[[i]], roc_g2_list[[i]], paired = T)
        p_values[i] <- test_result$p.value

        # Confidence intervals for each group
        CI_exp95 <- ci(roc_g1_list[[i]], conf.level = 0.95)
        CI_control95 <- ci(roc_g2_list[[i]], conf.level = 0.95)

        # AUC and confidence interval extraction
        auc_exp[i] <- CI_exp95[2]
        auc_control[i] <- CI_control95[2]
        conf_lowexp95[i] <- CI_exp95[1]
        conf_highexp95[i] <- CI_exp95[3]
        conf_lowcontrol95[i] <- CI_control95[1]
        conf_highcontrol95[i] <- CI_control95[3]

        # Difference in AUC
        Diff[i] <- auc_exp[i] - auc_control[i]

        # 95% confidence interval for the difference
        Diff_conf_low95[i] <- Diff[i] - (1.96 * (Diff[i] / test_result$statistic))
        Diff_conf_high95[i] <- Diff[i] + (1.96 * (Diff[i] / test_result$statistic))

        # 90% confidence interval for the difference
        Diff_conf_low90[i] <- Diff[i] - (1.645 * (Diff[i] / test_result$statistic))
        Diff_conf_high90[i] <- Diff[i] + (1.645 * (Diff[i] / test_result$statistic))

        # Store test statistic
        d[i] <- test_result$statistic
      }

      # Return p-values, AUCs, CIs, and differences
      return(list(
        p_values = p_values,
        auc_exp = auc_exp, auc_control = auc_control,
        conf_lowexp95 = conf_lowexp95, conf_highexp95 = conf_highexp95,
        conf_lowcontrol95 = conf_lowcontrol95, conf_highcontrol95 = conf_highcontrol95,
        Diff = Diff,
        Diff_conf_low95 = Diff_conf_low95, Diff_conf_high95 = Diff_conf_high95,
        Diff_conf_low90 = Diff_conf_low90, Diff_conf_high90 = Diff_conf_high90,
        d = d
      ))
    }

    results <- perform_roc_tests(roc_g1_list, roc_g2_list)

    # Power table
    power <- data.frame(
      "NHST" = mean(results$Diff_conf_low95 > 0 | results$Diff_conf_high95 < 0, na.rm=T),
      "ET" = mean(results$Diff_conf_low90 > -SESOI & results$Diff_conf_high90 < SESOI, na.rm = TRUE),
      "MET" = mean(results$Diff_conf_low95 > SESOI | results$Diff_conf_high95 < -SESOI, na.rm = TRUE),
      "AUC_diff" = mean(results$Diff)
    )

    # Create a summary text based on the power calculations
    summary_text <- paste(
      "The analysis yielded the following results:\n",
      "1. NHST (Null Hypothesis Significance Testing): ", round(power$NHST * 100, 2), "% of simulations rejected the null hypothesis at the 0.05 level\n",
      "2. ET (Equivalence Testing): ", round(power$ET * 100, 2), "% of simulations demonstrated equivalence within the specified smallest effect size of interest (SESOI)\n",
      "3. MET (Minimum-Effects Testing): ", round(power$MET * 100, 2), "% of simulations showed significant minimum effects in either direction relative to the SESOI\n",
      "4. AUC Difference: The mean difference in area under the ROC curves between groups is ", round(power$AUC_diff, 3), "\n",
      "\n",
      "Please report the following information for the power analysis section: \n",
      "Based on a simulation-based power analysis (Riesthuis et al., 2024), using the following parameters for: \n",
      "1. Group 1: mean signal =", mean_signal_g1,", signal sd =", sd_signal_g1,", mean noise =",mean_noise_g1, ", noise sd =",sd_noise_g1, "\n",
      "2. Group 2:  mean signal =", mean_signal_g2,", signal sd =", sd_signal_g2,", mean noise =",mean_noise_g2, ", noise sd =",sd_noise_g2, "\n",
      "3. Study: SESOI =", SESOI,", n =", n_g1,", number of studied items =",n_studied,", number of new items =", n_new,", correlation =", rho, "\n",
      "4. Simulation: number of simulations =", n_simulations, "set.seed = (2794)"
    )

    return(list(power_table = power, summary = summary_text))
  })


  output$power_table2_p_uv <- renderTable({
    paired_roc_uv()$power_table
  })

  output$summary_text_p_uv <- renderText({
    paired_roc_uv()$summary
  })

  # Estimate pAUCs
  estimate_pauc <- reactive({
    set.seed(2794)
    # Get input values
    mean_signal_g1 <- input$mean_signal_g1_pauc
    mean_signal_g2 <- input$mean_signal_g2_pauc
    mean_noise_g1 <- input$mean_noise_g1_pauc
    mean_noise_g2 <- input$mean_noise_g2_pauc
    sd_signal_g1 <- input$sd_signal_g1_pauc
    sd_signal_g2 <- input$sd_signal_g2_pauc
    sd_noise_g1 <- input$sd_noise_g1_pauc
    sd_noise_g2 <- input$sd_noise_g2_pauc
    n_studied <- input$n_studied_pauc
    n_new <- input$n_new_pauc
    low_bound <- input$low_bound
    up_bound <- input$up_bound

    # Sample size to get perfect AUC estimate
    n_g1 <- 10000

    # Correlation
    rho <- .0

    # Covariance matrix for correlated signal and noise
    cov_matrix_signal <- matrix(c(sd_signal_g1^2, rho * sd_signal_g1 * sd_signal_g2,
                                  rho * sd_signal_g1 * sd_signal_g2, sd_signal_g2^2), nrow = 2)
    cov_matrix_noise <- matrix(c(sd_noise_g1^2, rho * sd_noise_g1 * sd_noise_g2,
                                 rho * sd_noise_g1 * sd_noise_g2, sd_noise_g2^2), nrow = 2)

    # Generate correlated signal and noise for Group 1 and Group 2
    signal_data <- mvrnorm(n_g1 * n_studied, mu = c(mean_signal_g1, mean_signal_g2), Sigma = cov_matrix_signal)
    noise_data <- mvrnorm(n_g1 * n_new, mu = c(mean_noise_g1, mean_noise_g2), Sigma = cov_matrix_noise)

    # Combine signal and noise for both groups
    ratings_g1 <- c(signal_data[, 1], noise_data[, 1])
    ratings_g2 <- c(signal_data[, 2], noise_data[, 2])

    labels <- c(rep(1, n_g1 * n_studied), rep(0, n_g1 * n_new))

    # Define 6-point scale cutoffs (based on quantiles for balance)
    cutoffs_g1 <- quantile(ratings_g1, probs = seq(0, 1, length.out = 7))
    cutoffs_g2 <- quantile(ratings_g2, probs = seq(0, 1, length.out = 7))

    # Assign 6-point ratings for both groups
    ratings_g1 <- cut(ratings_g1, breaks = cutoffs_g1, labels = 1:6, include.lowest = TRUE)
    ratings_g2 <- cut(ratings_g2, breaks = cutoffs_g2, labels = 1:6, include.lowest = TRUE)

    # Convert to numeric for ROC calculations
    ratings_g1 <- as.numeric(ratings_g1)
    ratings_g2 <- as.numeric(ratings_g2)

    # Calculate paired ROC using pROC
    roc_g1 <- roc(labels, ratings_g1, direction = "<", partial.auc = c(low_bound,up_bound))
    roc_g2 <- roc(labels, ratings_g2, direction = "<", partial.auc = c(low_bound,up_bound))

    return(list(roc_g1 = roc_g1, roc_g2 = roc_g2, ratings_g1 = ratings_g1, ratings_g2 = ratings_g2, labels = labels))
  })

  output$roc_plot_g1_pauc <- renderPlot({
    roc_data <- estimate_pauc()
    if (!is.null(roc_data)) {
      par(pty="s")
      plot(roc_data$roc_g1, col = "blue", main = "ROC Curve - Group 1", legacy.axes=TRUE, xlab="False Positive Rate",
           ylab="True Postive Rate", print.auc=T,auc.polygon=TRUE)
    }
  })

  output$roc_plot_g2_pauc <- renderPlot({
    roc_data <- estimate_pauc()
    if (!is.null(roc_data)) {
      par(pty="s")
      plot(roc_data$roc_g2, col = "red", main = "ROC Curve - Group 2", legacy.axes=TRUE, xlab="False Positive Rate",
           ylab="True Postive Rate", print.auc=T,auc.polygon=TRUE)
    }
  })

}

# Run the application
shinyApp(ui = ui, server = server)
