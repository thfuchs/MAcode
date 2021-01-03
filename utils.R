toSlack <- function(message) {
  tryCatch({
    bin <- httr::POST(
      url = 'https://slack.com/api/chat.postMessage',
      body = list(token = Sys.getenv("SLACK_BOT"),
                  channel = Sys.getenv("SLACK_CHANNEL"),
                  text = message)
    )
    cont <- httr::content(bin)
    if (!cont$ok) message("Error in Slack API: ", cont$error)
    return(cont$ok)
  },
  error = function(err) {
    message("Error in toSlack: ", err)
    return(FALSE)
  },
  warning = function(war) {
    message("Warning in toSlack: ", war)
    return(FALSE)
  })
}

RDStoS3 <- function(data, filename, s3_prefix) {
  tryCatch({
    tmp <- tempdir()
    filepath <- file.path(tmp, filename)
    saveRDS(data, file = filepath, compress = "xz")
    bin <- aws.s3::put_object(
      file = filepath,
      object = paste0(s3_prefix, filename),
      bucket = Sys.getenv("AWS_BUCKET")
    )
    if (!bin) message("Error in AWS S3 API: Could not write file")
    return(bin)
  },
  error = function(err) {
    message("Error in RDStoS3: ", err)
    return(FALSE)
  },
  warning = function(war) {
    message("Warning in RDStoS3: ", war)
    return(FALSE)
  })
}
