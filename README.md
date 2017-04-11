# binning-optimization
Data analysis algorithm in R to determine which levels of a categorical variable one should keep

## Usage

Below is an example using a house dataset.

```R
# import binning optimization function
source("binning-optimization.R")

# loop through every categorical variable in the dataframe
# and find optimal binning
big_model = lm(SalePrice ~., data = house_data)
y = house_data$SalePrice
df = house_data
optimal_bins_list = list()

for (i in 1:length(house_data_cat_2b_optimized)) {
      print(names(house_data_cat_2b_optimized[i]))
        bin_results = search_optimal_bins(house_data_cat_2b_optimized[i], big_model, y, df)
          optimal_bins = bin_results$best_optimal_bins
            print(bin_results$best_p_value)
              optimal_bins_list[[i]] = optimal_bins
}

# apply the optimizations
optimized_categories = apply_optimal_bins(house_data_cat_2b_optimized, optimal_bins_list)
```

## Why Optimize Binning?
Binning optimization is very useful as it leads to the creation of simpler models and helps with level representation issues. The idea behind it is this:  
We can look at each categorical variable and determine which of its levels we could potentially group (or bin) together. For example, if we had a variable called ```EducationLevel```, there might be levels like “high school diploma” and “some college” that we could bin together under one level called “high school diploma”. Intuitively, this makes sense and would simplify our models, but these kinds of binnings must be statistically justified by performing F-tests and evaluating their p-values. But manually making these binning propositions for every categorical variable can be tedious which is why I created this repo. The algorithm looks at all the ways one could bin the levels in a given variable and chooses the one that has the highest p-value.

## How It WorksFirstly, I had to find out a way to count and generate all possible binnings given n objects (i.e. levels of the categorical variable) and k bins. After spending quite some time trying to derive this formula, I eventually stumbled across Stirling numbers of the second kind (which is just a special case of Bell numbers). This allowed me to count all possible combinations of binnings for n objects and k bins. Stirling numbers of the second kind grow very large as n increases which is why the code in this repo has max(n) = 10 as a computational practicality. The next hurdle was figuring out how I could actually generate all those possible binnings. Luckily, R has a package called ```partitions``` that helps to do this so all that was left was to calculate the F-test’s p-values for every possible binning and keep track of the highest p-value.

The algorithm works as follows for any given categorical variable:

```R
bin_range = 2:(length(levels) - 1)
top_optimal_bins = list()for k in bin_range:  get all possible ways you can bin the levels using k bins  find the optimal bin from the above by performing F-tests for every possible bin  store the optimal bin in top_optimal_bins listchoose the item in top_optimal_bins that has the highest p-value
```
