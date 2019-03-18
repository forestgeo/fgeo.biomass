Plot dbh vs. biomass by species
================

``` r
# Setup
library(tidyverse)
#> -- Attaching packages ---------------------------------------------- tidyverse 1.2.1 --
#> v ggplot2 3.1.0       v purrr   0.3.1  
#> v tibble  2.0.1       v dplyr   0.8.0.1
#> v tidyr   0.8.3       v stringr 1.4.0  
#> v readr   1.3.1       v forcats 0.4.0
#> Warning: package 'purrr' was built under R version 3.5.3
#> -- Conflicts ------------------------------------------------- tidyverse_conflicts() --
#> x dplyr::filter() masks stats::filter()
#> x dplyr::lag()    masks stats::lag()
library(fgeo.biomass)
```

-----

The goal is to plot dbh (x) versus biomass (y) by species
([issue](https://github.com/forestgeo/allodb/issues/73)).

Let’s first drop rows with missing `dbh` values as we can’t calculate
biomass for them.

``` r
census <- fgeo.biomass::scbi_tree1 %>% 
  filter(!is.na(dbh))
```

Let’s find allometric equations in allodb and calculate biomass.

``` r
species <- fgeo.biomass::scbi_species
census_species <- census %>% 
  add_species(species, site = "SCBI")
#> Adding `site`.
#> Overwriting `sp`; it now stores Latin species names.
#> Adding `rowid`.

census_equations <- allo_find(census_species)
#> Warning: Can't find equations matching these species (inserting 1159 missing values):
#> acer sp, carya sp, crataegus sp, fraxinus sp, juniperus virginiana, quercus prinus, quercus sp, ulmus sp, unidentified unk
#> Joining, by = sp, site.

biomass <- allo_evaluate(census_equations)
#> Assuming `dbh` unit in [mm].
#> Converting `dbh` based on `dbh_unit`.
#> Warning: Can't convert all units (inserting 1159 missing values):
#> the 'to' argument is not an acceptable unit.
#> `biomass` values are given in [kg].
#> Warning: Can't convert all units (inserting 1159 missing values):
#> the 'from' argument is not an acceptable unit.
#> Warning: Can't evaluate all equations (inserting 819 missing values):
#> object 'dba' not found
#> Warning: 
#>     `biomass` may be invalid.
#>     We still don't suppor the ability to select dbh-specific equations
#>     (see https://github.com/forestgeo/fgeo.biomass/issues/9).
#> 
biomass
#> # A tibble: 31,181 x 2
#>    rowid biomass
#>    <int>   <dbl>
#>  1     1   1.30 
#>  2     2   0.879
#>  3     3   0.750
#>  4     4 136.   
#>  5     5  NA    
#>  6     6  NA    
#>  7     7  NA    
#>  8     8   5.69 
#>  9     9  NA    
#> 10    10   0.211
#> # ... with 31,171 more rows
```

Now let’s plot `dbh` vs. `biomass` and use the preexisting `agb` column
as a coarse reference.

``` r
census_equations_biomass <- census_equations %>% right_join(biomass)
#> Joining, by = "rowid"

census_equations_biomass %>% 
  # Convert agb from [Mg] to [kg]
  mutate(agb_kg = agb * 1e3) %>% 
  ggplot(aes(dbh, biomass)) + 
  # Reference based on allometries for tropical trees
  geom_point(aes(y = agb_kg), color = "grey", size = 4) +
  geom_point(aes(y = biomass)) +
  ylab("Reference `agb` (grey) and calculated biomass (black) in [kg]") +
  xlab("dbh [mm]")
#> Warning: Removed 1159 rows containing missing values (geom_point).
#> Warning: Removed 1978 rows containing missing values (geom_point).
```

![](dbh-vs-biomass_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

Values over 40,000 appear to be outliers.

``` r
census_equations_biomass %>% 
  ggplot(aes(sp, biomass)) +
  geom_hline(yintercept = 4e4, color = "red") +
  geom_boxplot() +
  ylab("biomass [kg]") +
  coord_flip()
#> Warning: Removed 1978 rows containing non-finite values (stat_boxplot).
```

![](dbh-vs-biomass_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

Let’s identify the odd `rowid`s to later exclude them. This should
improve the plots. But we need to check if this equations are correct.
(Remember the code doesn’t yet handle height-dependent allometries;
could this be the problem?)

``` r
# Saving rowid to later exclude them
odd_rowids <- census_equations_biomass %>% 
  filter(biomass > 4e4) %>% 
  mutate(agb = agb * 1e3) %>% 
  select(rowid, sp, equation_id, eqn, biomass, agb) %>% 
  # Show the data as it is up to this point, then continue to get odd rowid
  print() %>% 
  pull(rowid) %>% 
  unique()
#> # A tibble: 3,692 x 6
#>    rowid sp               equation_id eqn                     biomass   agb
#>    <int> <chr>            <chr>       <chr>                     <dbl> <dbl>
#>  1    21 liriodendron tu~ 94f593      10^(0.8306 + 2.7308 *~   1.95e5  217.
#>  2    21 liriodendron tu~ c48e81      10^(-1.236 + 2.635 * ~   1.95e5  217.
#>  3   101 liriodendron tu~ 94f593      10^(0.8306 + 2.7308 *~   4.59e7 4378.
#>  4   101 liriodendron tu~ c48e81      10^(-1.236 + 2.635 * ~   4.59e7 4378.
#>  5   221 liriodendron tu~ 94f593      10^(0.8306 + 2.7308 *~   6.22e7 5637.
#>  6   221 liriodendron tu~ c48e81      10^(-1.236 + 2.635 * ~   6.22e7 5637.
#>  7   237 liriodendron tu~ 94f593      10^(0.8306 + 2.7308 *~   1.24e5  179.
#>  8   237 liriodendron tu~ c48e81      10^(-1.236 + 2.635 * ~   1.24e5  179.
#>  9   572 liriodendron tu~ 94f593      10^(0.8306 + 2.7308 *~   5.35e7 5536.
#> 10   572 liriodendron tu~ c48e81      10^(-1.236 + 2.635 * ~   5.35e7 5536.
#> # ... with 3,682 more rows

odd_rowids
#>    [1]    21   101   221   237   572   752   835   992  1137  1418  1430
#>   [12]  1497  1525  1540  1541  1551  1563  1615  1617  1645  1649  1665
#>   [23]  1679  1681  1688  1691  1692  1696  1706  1745  1748  1750  1755
#>   [34]  1758  1762  1764  1774  1802  1854  1933  1962  1977  1988  2010
#>   [45]  2016  2025  2033  2066  2067  2078  2079  2082  2088  2122  2126
#>   [56]  2133  2138  2141  2156  2167  2216  2224  2234  2236  2242  2728
#>   [67]  2740  2774  2803  2812  2815  2826  2852  2857  2859  2863  2866
#>   [78]  2868  2893  2913  2915  2933  2934  2946  2949  2953  2956  2957
#>   [89]  2969  2974  2979  2984  2985  2989  3033  3068  3090  3124  3155
#>  [100]  3161  3169  3193  3269  3279  3294  3321  3332  3351  3366  3418
#>  [111]  3432  3442  3460  3467  3475  3478  3479  3481  3492  3505  3516
#>  [122]  3517  3518  3528  3529  3536  3548  3554  3556  3559  3573  3578
#>  [133]  3579  3585  3590  3593  3598  3606  3610  3614  3616  3620  3625
#>  [144]  3626  3628  3630  3636  3641  3642  3645  3646  3651  3659  3662
#>  [155]  3672  3705  3875  3877  3896  3916  3971  3992  3998  4003  4022
#>  [166]  4024  4047  4079  4087  4089  4092  4096  4148  4149  4240  4292
#>  [177]  4309  4322  4351  4387  4412  4445  4465  4469  4476  4479  4482
#>  [188]  4492  4501  4504  4521  4546  4547  4563  4568  4587  4613  4614
#>  [199]  4624  4627  4628  4631  4635  4643  4646  4647  4660  4682  4696
#>  [210]  4705  4711  4712  4738  4743  4747  4759  4852  4868  4871  4876
#>  [221]  5031  5042  5061  5063  5106  5146  5148  5152  5285  5323  5353
#>  [232]  5398  5419  5428  5501  5522  5525  5535  5544  5550  5554  5567
#>  [243]  5574  5577  5578  5582  5587  5625  5643  5649  5684  5692  5697
#>  [254]  5712  5722  5725  5731  5732  5733  5740  5756  5761  5762  5767
#>  [265]  5768  5772  5774  5778  5783  5789  5792  5807  5810  5838  5843
#>  [276]  5866  5880  5881  5882  5889  5892  5893  5912  5913  5915  5922
#>  [287]  5930  5939  5940  5945  5947  5950  5951  5952  5966  5969  5970
#>  [298]  5971  5973  5974  5976  6028  6041  6042  6085  6195  6202  6207
#>  [309]  6210  6212  6214  6223  6233  6283  6286  6291  6298  6306  6311
#>  [320]  6352  6355  6363  6367  6372  6373  6385  6394  6413  6414  6416
#>  [331]  6420  6421  6428  6431  6437  6505  6508  6514  6516  6517  6521
#>  [342]  6524  6544  6570  6583  6587  6593  6594  6638  6648  6684  6699
#>  [353]  6703  6706  6782  6783  6784  6799  6806  6834  6846  6847  6854
#>  [364]  6893  6894  6895  6902  6904  6908  6911  6916  6923  6931  6933
#>  [375]  6934  6944  6947  6951  6953  6954  6957  6958  6959  6962  6965
#>  [386]  6967  6978  6980  6984  6986  6987  6988  6993  6994  7010  7076
#>  [397]  7085  7095  7104  7111  7124  7136  7205  7278  7288  7296  7420
#>  [408]  7426  7431  7513  7527  7542  7552  7556  7565  7656  7676  7705
#>  [419]  7718  7759  7763  7797  7814  7821  7837  7838  7841  7851  7852
#>  [430]  7853  7861  7863  7866  7868  7870  7878  7894  7897  7899  7901
#>  [441]  7902  7903  7906  7907  7911  7912  7913  7920  7942  7954  7955
#>  [452]  7958  7962  7963  7965  7967  7968  7970  7973  7980  7990  7995
#>  [463]  8011  8054  8070  8101  8127  8134  8135  8154  8182  8193  8196
#>  [474]  8275  8276  8277  8320  8328  8334  8345  8353  8359  8363  8378
#>  [485]  8386  8391  8397  8398  8415  8432  8455  8465  8484  8492  8495
#>  [496]  8497  8528  8548  8564  8565  8584  8587  8590  8601  8609  8623
#>  [507]  8635  8640  8739  8755  8756  8757  8769  8790  8811  8830  8839
#>  [518]  8851  8854  8859  8878  8894  8897  8902  8905  8909  8916  8917
#>  [529]  8919  8921  8924  8928  8930  8931  8932  8934  8936  8937  8957
#>  [540]  8958  8960  8962  8963  8966  8979  8980  8981  8985  8990  8991
#>  [551]  9001  9005  9011  9012  9015  9022  9023  9024  9038  9047  9050
#>  [562]  9062  9066  9078  9081  9082  9084  9085  9091  9134  9142  9157
#>  [573]  9193  9277  9283  9303  9307  9308  9313  9323  9325  9326  9327
#>  [584]  9360  9382  9411  9413  9479  9528  9535  9540  9581  9591  9598
#>  [595]  9621  9625  9637  9640  9683  9685  9692  9699  9743  9753  9776
#>  [606]  9783  9789  9810  9817  9844  9855  9887  9988 10037 10039 10041
#>  [617] 10042 10051 10056 10061 10064 10075 10076 10077 10078 10079 10083
#>  [628] 10100 10114 10116 10119 10122 10128 10134 10139 10142 10151 10163
#>  [639] 10167 10171 10173 10174 10176 10178 10179 10191 10192 10194 10196
#>  [650] 10201 10202 10208 10221 10222 10223 10229 10230 10232 10233 10235
#>  [661] 10236 10237 10238 10239 10240 10241 10246 10247 10250 10253 10255
#>  [672] 10256 10260 10262 10263 10265 10311 10373 10380 10397 10421 10422
#>  [683] 10472 10518 10536 10538 10603 10613 10625 10637 10668 10730 10736
#>  [694] 10753 10754 10757 10759 10772 10782 10832 10850 10896 10907 10911
#>  [705] 10916 10918 10922 10938 10939 10958 10970 10977 11009 11017 11040
#>  [716] 11041 11051 11068 11070 11084 11091 11098 11114 11130 11136 11138
#>  [727] 11139 11152 11160 11169 11197 11218 11233 11256 11272 11331 11336
#>  [738] 11338 11347 11349 11372 11403 11465 11486 11497 11508 11516 11517
#>  [749] 11520 11521 11522 11529 11530 11532 11552 11553 11557 11560 11561
#>  [760] 11566 11578 11579 11582 11589 11592 11603 11604 11606 11626 11628
#>  [771] 11630 11633 11639 11641 11643 11645 11646 11648 11650 11652 11656
#>  [782] 11658 11667 11668 11670 11671 11674 11676 11677 11679 11680 11685
#>  [793] 11686 11687 11688 11690 11691 11693 11699 11702 11707 11768 11770
#>  [804] 11829 12171 12176 12220 12265 12348 12367 12368 12429 12430 12485
#>  [815] 12489 12493 12497 12502 12508 12510 12511 12513 12524 12525 12526
#>  [826] 12531 12532 12536 12537 12540 12543 12546 12547 12551 12555 12560
#>  [837] 12562 12563 12571 12573 12599 12606 12641 12643 12651 12665 12681
#>  [848] 12685 12688 12693 12696 12698 12703 12710 12714 12758 12766 12785
#>  [859] 12791 12798 12821 12859 12934 12957 13045 13220 13231 13254 13264
#>  [870] 13297 13298 13301 13336 13344 13350 13354 13360 13362 13364 13366
#>  [881] 13369 13370 13371 13373 13374 13375 13376 13377 13378 13379 13380
#>  [892] 13382 13386 13387 13390 13397 13398 13401 13402 13404 13407 13408
#>  [903] 13410 13411 13412 13413 13416 13419 13420 13421 13422 13423 13424
#>  [914] 13433 13444 13445 13446 13447 13449 13503 13561 13573 13587 13709
#>  [925] 13723 13733 13798 14053 14151 14154 14161 14180 14201 14261 14271
#>  [936] 14273 14274 14279 14299 14305 14310 14311 14317 14328 14335 14337
#>  [947] 14352 14355 14359 14360 14361 14367 14376 14378 14384 14387 14392
#>  [958] 14395 14396 14398 14399 14402 14404 14408 14412 14414 14415 14418
#>  [969] 14429 14436 14437 14438 14451 14469 14477 14485 14487 14488 14492
#>  [980] 14493 14496 14497 14501 14509 14510 14517 14524 14536 14546 14556
#>  [991] 14558 14573 14581 14589 14620 14640 14657 14658 14666 14777
#>  [ reached getOption("max.print") -- omitted 846 entries ]
```

Let’s remove the odd `rowid`s and plot again, this time mapping each
species by color.

``` r
census_equations_biomass %>% 
  filter(!rowid %in% odd_rowids) %>% 
  # Convert agb from [Mg] to [kg]
  mutate(agb_kg = agb * 1e3) %>% 
  ggplot(aes(dbh)) + 
  # Reference based on allometries for tropical trees
  geom_point(aes(y = agb_kg), color = "grey", size = 4) +
  # Removing the legend to keep the plot simple
  geom_point(aes(y = biomass, color = sp)) +
  guides(color = "none") +
  ylab("Reference `agb` (grey) and calculated `biomass` (black) in [kg]") +
  xlab("dbh [mm]")
#> Warning: Removed 1159 rows containing missing values (geom_point).
#> Warning: Removed 1978 rows containing missing values (geom_point).
```

![](dbh-vs-biomass_files/figure-gfm/unnamed-chunk-8-1.png)<!-- -->

We can see two groups of data-points: Those that rise above about 10,000
kg and those that don’t. Let’s add a horizontal reference to clearly see
those groups, and let’s facet the plot to identify each species.

``` r
census_equations_biomass %>% 
  filter(!rowid %in% odd_rowids) %>% 
  # Convert agb from [Mg] to [kg]
  mutate(agb_kg = agb * 1e3) %>% 
  ggplot(aes(x = dbh)) +
  geom_hline(yintercept = 1e4, color = "red") +
  geom_point(aes(y = agb_kg), size = 1.5, color = "grey") +
  geom_point(aes(y = biomass), size = 1, color = "black") +
  facet_wrap("sp", ncol = 4) +
  ylab("Reference `agb` (grey) and calculated `biomass` (black) in [kg]") +
  xlab("dbh [mm]") +
  theme_bw()
#> Warning: Removed 1159 rows containing missing values (geom_point).
#> Warning: Removed 1978 rows containing missing values (geom_point).
```

![](dbh-vs-biomass_files/figure-gfm/unnamed-chunk-9-1.png)<!-- -->
