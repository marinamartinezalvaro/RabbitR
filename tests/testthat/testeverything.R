# test_that("iCreateParam works", {
#   iCreateParam()
# })
# library(testthat)
#
#

test_that("CreateParam returns expected structure", {
  # Assuming CreateParam() requires no arguments for this example
  params <- CreateParam()

  # Check if the return type is a list
  expect_type(params, "list")

  # Check for expected keys in the list based on your function's output
  expect_true(all(c("file.name", "na.codes", "hTrait", "pTrait") %in% names(params)))
})

test_that("Bunny function returns expected output", {
  # Assuming params is a list with necessary details for Bunny() function
  params <- list(file.name = "example.csv", na.codes = NA)

  # Mocking the params input for the purpose of this test
  bunny_result <- Bunny(params, Chain = FALSE)

  # Check if bunny_result is a list
  expect_type(bunny_result, "list")

  # Check for a specific structure or key within the result based on your implementation
  expect_true("ModelMean" %in% names(bunny_result))
})

test_that("Bayes function computes inferences correctly", {
  # Assuming we have a bunny list from the Bunny function
  # Here, you might need to mock this list or load it from a saved state
  bunny <- list(ModelMean = c(1, 2, 3)) # Example mock

  # Invoke Bayes function with necessary parameters and mocked bunny input
  bayes_result <- Bayes(params, bunny)

  # Check that bayes_result is a list and has expected structure
  expect_type(bayes_result, "list")

  # Check for specific keys or structure within bayes_result
  expect_true("ModelMean" %in% names(bayes_result))
})

test_that("Rabbit function integrates components correctly", {
  # Rabbit() might integrate all previous parts; thus, a comprehensive test could be challenging
  # Consider mocking internal calls or focusing on the integration aspect

  rabbit_result <- Rabbit()

  # Assuming Rabbit() returns a complex structure integrating all parts
  expect_type(rabbit_result, "list")

  # Validate a key component of the output
  expect_true("inferences" %in% names(rabbit_result))
})
