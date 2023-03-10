shuffle <- function(data, shuffle_vars, long_format, seed = seed) {

  if(is.null(shuffle_vars)) {
    return(data)
  }

  if(long_format) {
    row_nums <- data |> dplyr::group_by_at(shuffle_vars[[1]]) |> dplyr::summarise(n = dplyr::n()) |> dplyr::pull(n)
  } else {
    row_nums <- rep(1, nrow(data))
  }

  set.seed(seed)

  data <- shuffle_vars |>
    purrr::map_dfc(function(x){
      data |>
        dplyr::select(matches(x)) |>
        dplyr::mutate(rows = rep(1:length(row_nums), row_nums)) |>
        dplyr::group_split(rows) |>
        sample() |>
        dplyr::bind_rows() |>
        dplyr::select(-rows)
    }) |>
    dplyr::bind_cols(
      data |>
        dplyr::select(-matches(shuffle_vars))
    ) |>
    dplyr::select(names(data)) |>
    dplyr::arrange(across(matches(shuffle_vars[[1]])))

  data
}

validate_files <- function(...) {
  files <- as.list(...) |>
    unlist()

  if(any(!file.exists(files))) {
    error_files <- files[!file.exists(files)]
    cli::cli_abort("Could not find the following specified file{?s} in your project: {error_files}")
  }
}
