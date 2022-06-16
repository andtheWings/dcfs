wrangle_incidents <- function(incidents_raw_df) {
    
    # Derived from cross-referencing incidents_raw and hospital_addresses_raw
    # Consider filtering by hospital boundary as alternative:
    # https://hub-cookcountyil.opendata.arcgis.com/datasets/ac3888f022ab458da449e4634992ea68_8/explore
    hospital_address_variations <- c(
        # Alexian Brothers Behavioral Health Hospital
        "1650 Moon Lake Blvd",
        # Alexian Brothers Medical Center
        "800 Biesterfield Rd",
        # Amita Healh
        "1786 Moon Lake Blvd",
        # Chicago Metropolitan Obstetricians and Gynecologists
        "15620 Wood St",
        # Comer Children's Hospital
        "Comer Children's Hospital",
        "Comer's Children Hospital",
        "University of Chicago Comer Children's Hospital",
        # Christ Hospital & Med Cntr
        "4440 W 95th St",
        "4440 W 95th St-Advocate Christ Medical Center",
        "4440 W 95th Street",
        # Columbia Lagrange Memorial Hospital
        "5101 Willow Springs Rd",
        # Erie Family Health Center
        "1701 W Superior St",
        # Evanston Hospital
        "2650 Ridge Ave",
        # Foster G Mc Gaw Hospital
        "2160 S 1st Ave",
        # Garfield Park Hospital
        "520 N Ridgeway Ave",
        "520 N Ridgeway Avenue",
        # Gottlieb Memorial Hospital
        "701 W North Ave",
        # Hartgrove Hospital
        "5730 W Roosevelt Rd",
        "5730 W. roosevelt",
        # Hektoen Institute
        "1901 W Harrison St",
        # Hines VA Medical Center
        "5000 S 5th Ave",
        # Holy Cross Hospital
        "2701 W  68th St",
        "2701 W 68th St",
        "2701 W 68TH STREET",
        # Holy Family Hospital
        "100 N River",
        # Humboldt Park Health
        "1044 N Francisco",
        "1044 N Francisco Ave",
        # Illinois Masonic Medical Center
        "836 W Wellington Ave",
        # Ingalls Memorial
        "1 Ingalls Dr",
        "1 Ingalls Dr.",
        # Jackson Park
        "7531 S Stony Island Ave",
        # John F. Kennedy Medical Center
        "5645 W Addison St",
        # Larabida Children Hospital & Res Ctr
        "6501 S Promontory Dr",
        # Lurie
        "225 E Chicago Ave",
        "225 E Chicago Avenue",
        "225 E. Chicago Ave.",
        # Little Company of Mary
        "2800 W 95th St",
        # Louis A Weiss Memorial Hospital
        "4646 N Marine Dr",
        # Lutheran General Hospital Inc
        "1775 Dempster St",
        "1775 Dempster Street",
        # Mac Neal Memorial Hospital
        "3249 Oak Park Ave",
        # Mercy Hospital & Medical Center
        "2525 S Michigan Ave",
        # MetroSouth Medical Center
        "2310 York St",
        # Mitchell Hospital
        "5815 S Maryland Ave",
        # Mt Sinai
        "1500 S Fairfield Ave",
        "2755 W 15th St",
        # Northwest Community Hospital
        "800 W Central Rd",
        # Northwestern Medical Faculty Foundation
        "675 N Saint Clair St",
        # Northwestern Memorial
        "251 E Huron St",
        "251 E Huron Street",
        # Norwegian American Hospital
        "1044 N. Francisco",
        "1044 N Francisco Ave",
        "1044 N Francisco",
        # Oak Park
        "520 S Maple Ave",
        # Palos Community Hospital
        "12251 S 80th Ave",
        # Provident Hospital Of Cook County
        "500 E 51st St",
        # Resurrection Medical Center
        "7435 W Talcott Ave",
        # Riveredge
        "8311 Roosevelt Rd",
        # Roseland CLinic
        "11250 South Halsted Street",
        # Roseland Community
        "45 W 111st",
        "45 W 111th St",
        "45 W. 111th St",
        # Rush University
        "1653 W Congress Pkwy",
        "1653 W Harrison St",
        "1653 W. CONGRESS PKWY",
        "1620 W Harrison St",
        # Rush University Children's
        "1620 W Harrison St",
        # St. Anthony
        "2875 W 19th St",
        "2875 W. 19th Street",
        # Saint Alexius Medical Center
        "1555 Barrington Rd",
        # Skokie Hospital
        "9600 Gross Point Rd",
        # South Chicago Community
        "2320 E 93rd St",
        # South Suburban
        "17800 Kedzie Ave",
        # St. Anthony
        "2875 W 19th St",
        "2875 W. 19th Street",
        # St. Bernards
        "326 W 64TH PLACE",
        "326 W 64th St",
        # St. Elizabeth
        "1431 N Claremont Ave",
        # St. Francis
        "355 Ridge Ave",
        # St Francis Hospital (metrosouth Medical Center)
        "12935 Gregory St",
        "12935 Gregory St.",
        # St James Hosp & Health Center-oly Fields
        "20201 Crawford Ave",
        # St. James
        "1423 Chicago Rd",
        "1423 Chicago Rd, St. James Hospital",
        # St. Josephs
        "2900 N Lake Shore Dr",
        # St. Mary of Nazareth
        "2233 W Division",
        "2233 W Division St",
        # Streamwood Behavioral Healthcare System
        "1400 E Irving Park Rd",
        # Stroger Hospital
        "1969 W. Ogden",
        "1969 W Ogden Ave",
        "1969 Odgen Avenue",
        "1969 W. Ogden Ave",
        "1969 Ogden Ave",
        "1969 W. Polk st",
        # Swedish Covenant
        "5145 N California Ave",
        # Thorek Medical Center
        "850 W Irving Park Rd",
        # UI Health
        "1740 W Taylor St",
        "1740 W Taylor St, U of I",
        "1740 S. Taylor",
        "1740 W. Taylor St.",
        # University of Chicago Medical Center
        "5841 S MARYLAND",
        "5841 S Maryland Ave",
        "5841 S. Maryland",
        # Vet Administration West Side Hospital
        "820 S Damen Ave",
        # West Suburban Hospital Medical Center
        "1 Erie Ct",
        "3 Erie Ct",
        "3 Erie Ct Ste 1300",
        "3 Erie West Suburban",
        # Westlake Community Hospital
        "1225 W Lake St"
    )
    
    df1 <-
        incidents_raw_df |> 
        # Without address filter --> 12176 incidents
        # With address filter --> 11517 incidents
        filter(
            !(IN_Street %in% hospital_address_variations)
        ) |> 
        select(
            status = Status,
            person_of_interest = USER_Inves, 
            victim = USER_Victi,
            date = USER_Repor,
            allegation = USER_Alleg,
            judgement_of_alleg = USER_All_1,
            lat = INTPTLAT, 
            long = INTPTLON
        ) |> 
        filter(!is.na(lat) & !is.na(long)) |> 
        filter(judgement_of_alleg %in% c("Indicated", "Indicated Allowed")) |> 
        separate(
            allegation,
            into = c("allegation_code", "allegation_desc"),
            sep = "-",
            extra = "merge"
        ) |> 
        mutate(
            allegation_code_num = 
                as.numeric(
                    str_extract(allegation_code, "[:digit:]+")
                ),
            abuse_or_neglect =
                case_when(
                    allegation_code_num %in% 1:40 ~ "abuse",
                    allegation_code_num %in% 51:90 ~ "neglect"
                ),
            spatiotemporal_id = 
                paste(
                    date, lat, long,
                    sep = ":"
                )
        )
    
    df2 <-
        df1 |> 
        group_by(spatiotemporal_id) |> 
        summarize(
            abuse = any(str_detect(abuse_or_neglect, "abuse")),
            neglect = any(str_detect(abuse_or_neglect, "neglect"))
        ) |> 
        right_join(df1) |> 
        group_by(
            spatiotemporal_id, date, lat, long,
            abuse, neglect
        ) |>
        nest() |>
        st_as_sf(
            coords = c("long", "lat"),
            crs = 4269
        ) #|>
        #st_transform(crs = 4326)

    return(df2)
    
}