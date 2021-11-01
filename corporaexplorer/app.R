library(corporaexplorer)
corpus <- readRDS("../rshiny_dashboard/saved_corporaexplorerobject_no_timeline.rds")
explore(corpus,ui_options = list(font_size = "14px"), plot_options = list(plot_size_factor=2.5))
