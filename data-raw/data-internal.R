.default_eqn <- default_eqn(allodb::master())
.bad_eqn_id <- bad_eqn_id(allodb::master())

usethis::use_data(
  .default_eqn,
  .bad_eqn_id,
  internal = TRUE, overwrite = TRUE
)

