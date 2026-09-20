allocate_dhondt_batch <- function(votes, ballots_cast, minority_flags, n_seats = 250, threshold = 0.03) {
  votes <- as.matrix(votes)
  n <- nrow(votes); k <- ncol(votes)
  if (length(ballots_cast) != n) stop("Dužina vektora izlaznosti nije usklađena sa matricom glasova.")
  if (length(minority_flags) != k) stop("Status manjinske liste nije usklađen sa kolonama glasova.")

  threshold_votes <- ballots_cast * threshold
  meets <- votes >= threshold_votes
  ordinary <- matrix(!minority_flags, nrow = n, ncol = k, byrow = TRUE)
  minority_m <- !ordinary

  eligible <- (ordinary & meets) | minority_m
  none_overall <- rowSums(meets) == 0
  if (any(none_overall)) eligible[none_overall, ] <- votes[none_overall, , drop = FALSE] > 0

  effective_votes <- votes
  below_minority <- minority_m & !meets
  effective_votes[below_minority] <- effective_votes[below_minority] * 1.35
  effective_votes[!eligible] <- 0

  seats <- matrix(0L, nrow = n, ncol = k, dimnames = dimnames(votes))
  for (s in seq_len(n_seats)) {
    q <- effective_votes / (seats + 1)
    winner <- max.col(q, ties.method = "first")
    idx <- cbind(seq_len(n), winner)
    seats[idx] <- seats[idx] + 1L
  }
  seats
}

allocate_dhondt_single <- function(votes, ballots_cast, minority_flags, n_seats = 250, threshold = 0.03) {
  m <- matrix(votes, nrow = 1, dimnames = list(NULL, names(votes)))
  as.integer(allocate_dhondt_batch(m, ballots_cast, minority_flags, n_seats, threshold)[1, ])
}
