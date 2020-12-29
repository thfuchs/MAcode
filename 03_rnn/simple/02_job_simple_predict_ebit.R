######################## 02_job_simple_predict_ebit.R ##########################

################################################################################
### Training and forecasting on cross-validation splits with tuned parameters ##
################################################################################

source("settings.R")
source("utils.R")

data_ebit_test <- readRDS("data/data_ebit.rds")[ticker == "BA_UN", .(index, value)]
load("03_rnn/simple/fc_ebit_test_rnn_bayes.rda")

fc_ebit_test_rnn_prediction <- tune_keras_rnn_predict(
  data = data_ebit_test[1:52],
  col_id = NULL, col_date = "index", col_value = "value",
  model_type = "simple",
  cv_setting = cv_setting_test,
  bayes_best_par = purrr::map(fc_ebit_test_rnn_bayes, "Best_Par"),
  iter_dropout = 100,
  save_model = NULL
  # save_model_id = "ebit"
)

save(fc_ebit_test_rnn_prediction, file = "03_rnn/simple/fc_ebit_test_rnn_prediction.rda")

# Success Message
toSlack("Simple RNN EBIT (Test) prediction finished")
