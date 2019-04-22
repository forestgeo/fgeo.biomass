#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
NumericVector convert_unitsC(NumericVector x, String from, String to) {
  int n = x.size();
  NumericVector out(n);

  if (from == to) {
    out = x;
  }

  if (from == "cm" && to == "mm") {
    for(int i = 0; i < n; ++i) {
      out[i] = (x[i] * 10);
    }
  }

  if (from == "cm" && to == "m") {
    for(int i = 0; i < n; ++i) {
      out[i] = (x[i] / 100);
    }
  }

  return out;
}

/***R
bench::mark(
  convert_unitsC(1:3,          from = "cm", to = "mm"),
  measurements::conv_unit(1:3, from = "cm", to = "mm")
)
*/

