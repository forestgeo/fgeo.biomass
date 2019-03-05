.default_eqn <- default_eqn(allodb::master())
failing_eqn_id <- pull_failing_eqn(allodb::master())

usethis::use_data(
  .default_eqn,
  failing_eqn_id,
  internal = TRUE, overwrite = TRUE
)

