toSlack <- function(message) {
  content <- jsonlite::toJSON(list(list(
    type = "section",
    text = list(type = "mrkdwn", text = message)
  )), auto_unbox = TRUE)

  bin <- httr::POST(
    url = 'https://slack.com/api/chat.postMessage',
    body = list(token = Sys.getenv("SLACK_BOT"),
                channel = Sys.getenv("SLACK_CHANNEL"),
                `blocks` = paste(content))
  )
}
