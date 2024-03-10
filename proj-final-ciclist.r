library(tidyverse)  # Ajuda a organizar e Visualizar dados
library(lubridate)  # Ajuda a organizar atributos de datas

# Alterando o diretório de trabalho:
setwd("Downloads/aulas/csv-proj-final")

# Importando os dados atualizados [os 12 meses de 2023]:
jan_2023 <- read_csv("202301-divvy-tripdata.csv")
fev_2023 <- read_csv("202302-divvy-tripdata.csv")
mar_2023 <- read_csv("202303-divvy-tripdata.csv")
abr_2023 <- read_csv("202304-divvy-tripdata.csv")
mai_2023 <- read_csv("202305-divvy-tripdata.csv")
jun_2023 <- read_csv("202306-divvy-tripdata.csv")
jul_2023 <- read_csv("202307-divvy-tripdata.csv")
ago_2023 <- read_csv("202308-divvy-tripdata.csv")
set_2023 <- read_csv("202309-divvy-tripdata.csv")
out_2023 <- read_csv("202310-divvy-tripdata.csv")
nov_2023 <- read_csv("202311-divvy-tripdata.csv")
dez_2023 <- read_csv("202312-divvy-tripdata.csv")

# Armazenando os nomes das colunas de cada mês em variáveis
nome_col_jan <- colnames(jan_2023)
nome_col_fev <- colnames(fev_2023)
nome_col_mar <- colnames(mar_2023)
nome_col_abr <- colnames(abr_2023)
nome_col_mai <- colnames(mai_2023)
nome_col_jun <- colnames(jun_2023)
nome_col_jul <- colnames(jul_2023)
nome_col_ago <- colnames(ago_2023)
nome_col_set <- colnames(set_2023)
nome_col_out <- colnames(out_2023)
nome_col_nov <- colnames(nov_2023)
nome_col_dez <- colnames(dez_2023)

# Comparando os nomes de colunas
nome_col_jan == nome_col_fev
nome_col_jan == nome_col_mar
nome_col_jan == nome_col_abr
nome_col_jan == nome_col_mai
nome_col_jan == nome_col_jun
nome_col_jan == nome_col_jul
nome_col_jan == nome_col_ago
nome_col_jan == nome_col_set
nome_col_jan == nome_col_out
nome_col_jan == nome_col_nov
nome_col_jan == nome_col_dez

# Juntando os data frames separados
all_trips <- bind_rows(jan_2023,fev_2023,mar_2023,abr_2023,mai_2023,jun_2023,jul_2023,ago_2023,set_2023,out_2023,nov_2023,dez_2023)

# Inspecionando a tabela
colnames(all_trips)  	#Lista os nomes das colunas
nrow(all_trips)  		#Número de linhas no data frame
dim(all_trips) 	 		#Dimensões do data frame
head(all_trips)  		#Visualiza as primeiras 6 linhas do data frame
tail(all_trips)			#Visualiza as primeiras 6 linhas do data frame
str(all_trips)  		#Visualiza a lista de colunas e tipos de dados (numérico, caractere, etc)
summary(all_trips)  	#Sumário estatístico dos dados

# Removendo colunas não usadas de latitude, longitude e nomes de estação
all_trips <- all_trips %>%  
  select(-c(start_lat, start_lng, end_lat, end_lng, start_station_id, end_station_id, start_station_name, end_station_name))

# Adicionando colunas que listam a data, como mês, dia e dia da semana de cada passeio
all_trips$date <- as.Date(all_trips$started_at) 			# O formato padrão é yyyy-mm-dd
all_trips$month <- format(as.Date(all_trips$date), "%m")    # Meses em formato numérico
all_trips$day <- format(as.Date(all_trips$date), "%d")      # Dia do mês
all_trips$day_of_week <- format(as.Date(all_trips$date), "%A")

# Transforma os meses de formato numérico para texto
all_trips$month <- month(all_trips$started_at, label = TRUE, abbr = TRUE)

# Obtendo as horas do dia
all_trips$hour_of_day <- strftime(all_trips$started_at, "%H")    

# Adiciona um cálculo de duração do passeio que é a diferença entre o tempo final e inicial para todos os passeios (em segundos)
all_trips$ride_length <- difftime(all_trips$ended_at,all_trips$started_at)

# Convertendo a coluna "ride_length" para numérico e assim permitir cálculos nos dados
is.factor(all_trips$ride_length)
all_trips$ride_length <- as.numeric(as.character(all_trips$ride_length))
is.numeric(all_trips$ride_length)

# Removendo dados "ruins" com valores negativos
all_trips_v2 <- all_trips[!(all_trips$ride_length<0),]

# Estatística descritiva na duração do passeio [tudo em segundos]
mean(all_trips_v2$ride_length) 		#Média direta (duração do passeio total / passeios)
median(all_trips_v2$ride_length) 	#Número de ponto médio no conjunto ascendente de duração do passeio
max(all_trips_v2$ride_length) 		#Passeio mais longo
min(all_trips_v2$ride_length) 		#Passeio mais curto

# Comparar membros e usuários casuais
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = mean)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = median)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = max)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = min)

# Ver o tempo de passeio médio em cada dia para membros vs usuários casuais
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)

# Analisando dados dos ciclistas por tipo e dia da semana
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>%  		# Cria um campo dia da semana usando wday()
  group_by(member_casual, weekday) %>%  						# Agrupa por tipo de usuário e dia da semana
  summarise(number_of_rides = n()                               # Calcula o número de passeios e  
  ,average_duration = mean(ride_length)) %>%                 	# Calcula a duração média
  arrange(member_casual, weekday)								# Classifica

# Criando um gráfico do número de passeios por tipo de ciclista
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday)  %>% 
  ggplot(aes(x = weekday, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(title="Quantidade de passeios por tipo de ciclista",x="Dia da Semana",y="Quantidade de Passeios", fill= "Membro ou Casual")

# Criando um gráfico da duração média dos passeios por semana
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday)  %>% 
  ggplot(aes(x = weekday, y = average_duration, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(title="Duração média dos passeios por tipo de ciclista",x="Dia da Semana",y="Duração Média", fill= "Membro ou Casual")
            
# Criando um gráfico da quantidade dos passeios por mês para cada tipo de ciclista
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, month) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, month)  %>% 
  ggplot(aes(x = month, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(title="Quantidade de passeios por mês para cada tipo de ciclista",x="Mês",y="Duração Média", fill= "Membro ou Casual")            

# Criando um gráfico da quantidade dos passeios por hora do dia para cada tipo de ciclista
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, hour_of_day) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, hour_of_day)  %>% 
  ggplot(aes(x = hour_of_day, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(title="Quantidade de passeios por hora do dia para cada tipo de ciclista",x="Hora do dia",y="Duração Média", fill= "Membro ou Casual")


