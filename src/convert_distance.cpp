#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
NumericVector convert_distance(NumericVector x, String from, String to) {
  int n = x.size();
  NumericVector out(n);

  if (!(from == "inch" || from == "cm" || from == "mm")) {
    for (int i = 0; i < n; i++) {
      out[i] = NA_REAL;
    }
    return out;
  }

  if (!(to == "inch" || to == "cm" || to == "mm")) {
    for (int i = 0; i < n; i++) {
      out[i] = NA_REAL;
    }
    return out;
  }

  if (from == to) {
    return x;
  }

  if (from == "inch" && to == "mm") {
    out = x * 25.4;
  }

  if (from == "mm" && to == "inch") {
    out = x / 25.4;
  }

  if (from == "inch" && to == "cm") {
    out = x * 2.54;
  }

  if (from == "cm" && to == "inch") {
    out = x / 2.54;
  }

  if (from == "cm" && to == "mm") {
    out = x * 10;
  }

  if (from == "mm" && to == "cm") {
    out = x / 10;
  }

  return out;
}

/***R
convert_distance(1:3, "cm", "bad")
convert_distance(1:3, "bad", "m")

convert_distance(1:3, "cm", "mm")
convert_distance(1:3, "cm", "inch")
convert_distance(1:3, "inch", "mm")
convert_distance(1:3, "cm", "inch")
*/
