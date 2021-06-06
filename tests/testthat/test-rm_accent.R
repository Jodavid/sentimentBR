test_that("multiplication works", {
  expect_equal(rm_accent("São Paulo"), "Sao Paulo")
  expect_equal(rm_accent("Brasília"), "Brasilia")
  expect_equal(rm_accent(c("João Pessoa", "cabeça")), c("Joao Pessoa", "cabeca"))
})
