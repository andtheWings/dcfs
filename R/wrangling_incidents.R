wrangle_incidents <- function(incidents_raw_df) {
    
    df1 <-
        incidents_raw_df |> 
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