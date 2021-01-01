toSlack <- function(message) {
  bin <- httr::POST(
    url = 'https://slack.com/api/chat.postMessage',
    body = list(token = Sys.getenv("SLACK_BOT"),
                channel = Sys.getenv("SLACK_CHANNEL"),
                text = message)
  )
  cont <- httr::content(bin)
  if (!cont$ok) message("Error in toSlack: ", cont$error)
  return(cont$ok)
}
