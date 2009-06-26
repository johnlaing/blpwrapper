java_init()
conn <- create_session_and_service()

request <- prepare_request(conn$service, c("IBM US Equity", "MSFT US Equity"), c("PX_LAST", "NAME"))
submit_request(conn$session, request)

read_events_stream_to_string(conn$session)
