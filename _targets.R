library(targets)

source("R/wrangling_addresses.R")
source("R/wrangling_incidents.R")

tar_option_set(
    packages = c(
        "dplyr", "purrr", "readr", "stringr", "tidyr",
        "leaflet", "sf"
    )
)

list(
    # Cook County Boundary
    tar_target(
        cook_county_boundary_file,
        # https://hub-cookcountyil.opendata.arcgis.com/datasets/ea127f9e96b74677892722069c984198_1/explore
        "data/Cook_County_Border.geojson",
        format = "file"
    ),
    tar_target(
        cook_county_boundary,
        st_read(cook_county_boundary_file)
    ),
    # Hospital Addresses
    tar_target(
        hospital_addresses_raw_file,
        # From Wei Gao in email on 6/3/22
        "data/xdro_hospital_address_xy_20220603.xlsx"
    ),
    tar_target(
        hospital_addresses_raw,
        readxl::read_xlsx(hospital_addresses_raw_file)
    ),
    tar_target(
        cook_hospital_addresses,
        wrangle_cook_hospital_addresses(hospital_addresses_raw, cook_county_boundary)
    ),
    # DCFS Incidents
    tar_target(
        incidents_raw_file,
        # From Huiyuan Zhang in email on 5/20/22
        "data/CookCountyHospitalDataPull811673121_XY_GEOID_TableToExcel.xlsx",
        format = "file"
    ),
    tar_target(
        incidents_raw,
        readxl::read_xlsx(incidents_raw_file)
    ),
    tar_target(
        incidents,
        wrangle_incidents(incidents_raw)
    ),
    # Tidycensus Pull
    tar_target(
        cook_census_pop_and_polygons,
        tidycensus::get_acs(
            geography = "tract",
            variables = "B01001_001", # Total pop
            year = 2019,
            state = 17, # Illinois
            county = 031, # Cook County
            geometry = TRUE,
            survey = "acs5"
        )
    ),
    tar_target(
        cook_incidents_per_census_tract,
        mutate(
            .data = cook_census_pop_and_polygons,
            count_incidents = 
                lengths(
                    st_intersects(cook_census_pop_and_polygons, incidents)
                )
        )
    )
)