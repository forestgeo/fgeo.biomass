failing_eqn_id <- fixme_pull_failing_eqn(allodb::master())

usethis::use_data(
  failing_eqn_id,
  overwrite = TRUE
)
