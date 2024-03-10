


Este é um estudo de caso para a conclusão do curso de análise de dados do Google realizado através do Coursera.

#### Introdução

A análise desse estudo de caso é sobre o compartilhamento de bicicletas em Chicago de uma empresa fictícia, a Cyclistic, que conta com mais de 5.800 bicicletas e 600 estações de compartilhamento.

Os clientes que adquirem passes de viagem única ou de dia inteiro são chamados de ciclistas casuais.
Os clientes que adquirem planos anuais são chamados de ciclistas membros.

A equipe de marketing tem como objetivo criar estratégias destinadas a converter ciclistas casuais em membros anuais.
Para isso, a equipe precisa entender melhor como os ciclistas membros e os ciclistas casuais diferem e portanto estão interessados em analisar os dados históricos de trajetos de bicicleta da Cyclistic para identificar tendências.

#### Pergunta da tarefa de negócios

Como os ciclistas membros e os ciclistas casuais usam as bicicletas da Cyclistic de forma diferente?


#### Fontes de dados usadas

Para os propósitos deste estudo de caso, os conjuntos de dados utilizados são dados públicos que foram disponibilizados pela Motivate International Inc. através do seguinte endereço: https://divvy-tripdata.s3.amazonaws.com/index.html e sob a seguinte licença de uso https://www.divvybikes.com/data-license-agreement.

Os dados mais recentes (a partir do ano 2020) estão organizados no formato yyyymm-divvy-tripdata.zip e contém um arquivo *csv* com o mesmo formato de nome.
Os arquivos utilizados foram os dos meses janeiro até dezembro de 2023.

#### Ferramenta utilizada
Foi escolhido para a análise desses dados a utilização de R. Isso foi devido ao grande tamanho da fonte de dados, impossibilitando a análise em ferramentas como planilhas, por exemplo. Outra possibilidade seria a análise com alguma ferramenta de banco de dados como o SQLite e a visualização gráfica com Tableau.

#### Análise descritiva

Para a análise, precisamos instalar as bibliotecas **_tidyverse_** e **_lubridate_** :

```
install.packages("tidyverse")
install.packages("lubridate")
```

Carregando as bibliotecas:

```
library(tidyverse)
library(lubridate)
```

A biblioteca **_tidyverse_** é uma coleção de pacotes ou *scripts* do R. Fazem parte os seguintes *scripts*: ggplot2, tibble, tidyr, readr, purrr, dplyr, stringr, forcats, que são utilizados para manipulação, exploração e visualização de dados.
A biblioteca **_lubridate_** é um *script* que permite trabalhar com dados de data e hora no R.

Vamos verificar o diretório de trabalho padrão do R:

```
getwd()
```

E alterar para o diretório de sua preferência:

```
setwd("Downloads/aulas/csv-proj-final")
```

Agora iniciamos a leitura e importação dos arquivos em formato *csv* para variáveis em R: 

```
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
```

Extraindo os nomes das colunas para variáveis em R:

```
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
```

Vamos comparar os nomes das colunas de cada arquivo:

```
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
```

Agora vamos Juntar os data frames separados por meses em um único:

```
all_trips <- bind_rows(jan_2023,fev_2023,mar_2023,abr_2023,mai_2023,jun_2023,jul_2023,ago_2023,set_2023,out_2023,nov_2023,dez_2023)
```

Vamos agora realizar a limpeza e preparação dos dados para análise
removendo as colunas não usadas:

```
all_trips <- all_trips %>%  
  select(-c(start_lat, start_lng, end_lat, end_lng, ride_id, start_station_id, end_station_id, start_station_name, end_station_name))
```

Para inspecionar o data frame com a nova tabela criada podemos usar vários comandos:

```
colnames(all_trips)		#Mostra os nomes das colunas
nrow(all_trips)			#Conta o número de linhas
dim(all_trips)			#Mostra as dimensões de uma matriz ou vetor
head(all_trips)			#Mostra o início
tail(all_trips)			#Mostra o fim
str(all_trips)			#Mostra a estrutura interna
summary(all_trips)		#Mostra as estatísticas resumidas
```

Precisamos adicionar agora as colunas que listam a data, o mês e o dia de cada passeio:

```
all_trips$date <- as.Date(all_trips$started_at)		# O formato padrão é yyyy-mm-dd
all_trips$month <- month(all_trips$started_at, label = TRUE, abbr = TRUE)
all_trips$day <- format(as.Date(all_trips$date), "%d")		# Dia do mês
all_trips$day_of_week <- format(as.Date(all_trips$date), "%A")
all_trips$hour_of_day <- strftime(all_trips$started_at, "%H")
```

Adicionando um cálculo de duração do passeio que é a diferença entre o tempo final e inicial para todos os passeios (em segundos):

```
all_trips$ride_length <- difftime(all_trips$ended_at,all_trips$started_at)
```

Convertendo a coluna "ride_length" para numérico e assim permitir cálculos nos dados:

```
all_trips$ride_length <- as.numeric(as.character(all_trips$ride_length))
is.numeric(all_trips$ride_length)
```

Removendo dados "ruins" com valores negativos

```
all_trips_v2 <- all_trips[!(all_trips$ride_length<0),]
```


Análise descritiva na duração do passeio [tudo em segundos]

```
mean(all_trips_v2$ride_length) 		#Média direta (duração do passeio total / passeios)
median(all_trips_v2$ride_length) 	#Número de ponto médio no conjunto ascendente de duração do passeio
max(all_trips_v2$ride_length) 		#Passeio mais longo
min(all_trips_v2$ride_length) 		#Passeio mais curto
```

Comparando usuários membros e usuários casuais:

```
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = mean)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = median)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = max)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = min)
```

Vamos agregar a média de tempo de passeio por cada dia para usuários membros e para usuários casuais:

```
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)
```

Analisando dados dos ciclistas por tipo e dia da semana:

```
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>%  		# Cria um campo dia da semana usando wday()
  group_by(member_casual, weekday) %>%  						# Agrupa por tipo de usuário e dia da semana
  summarise(number_of_rides = n()                               # Calcula o número de passeios e  
  ,average_duration = mean(ride_length)) %>%                 	# Calcula a duração média
  arrange(member_casual, weekday)								# Classifica
```

Criando um gráfico da quantidade de passeios por tipo de ciclista na semana:

```
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday)  %>% 
  ggplot(aes(x = weekday, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(title="Quantidade de passeios por tipo de ciclista",x="Dia da Semana",y="Número de Passeios", fill= "Membro ou Casual")
```

![alternate text](./Rplot1.jpg "Title")

No gráfico acima, podemos perceber que os usuários membros realizam mais passeios que os usuários casuais em qualquer dia da semana. Os usuários membros realizam mais passeios durante os dias úteis da semana e um pouco menos durante o fim de semana. Já para os usuários casuais ocorre o oposto, os usuários casuais realizam mais passeios durante o fim de semana.

Criando um gráfico da duração média dos passeios por tipo de ciclista na semana:

```
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday)  %>% 
  ggplot(aes(x = weekday, y = average_duration, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(title="Duração média dos passeios por tipo de ciclista",x="Dia da Semana",y="Duração Média", fill= "Membro ou Casual")
```

![alternate text](./Rplot2.jpg "Title")

No gráfico acima, podemos observar que a duração média dos passeios para os usuários membros se manteve praticamente constante durante a semana, com um aumento mínimo nos finais de semana. Para os usuários casuais a duração média dos passeios na semana é bem superior aos usuários membros, bem como um aumento mais expressivo nos finais de semana.

Criando um gráfico da quantidade dos passeios por mês para cada tipo de ciclista:

```
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, month) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, month)  %>% 
  ggplot(aes(x = month, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(title="Quantidade de passeios por mês para cada tipo de ciclista",x="Mês",y="Duração Média", fill= "Membro ou Casual")
```

![alternate text](./Rplot3.jpg "Title")

No gráfico acima, observamos que a quantidade de passeios para os ciclistas membros foram maiores do que para os ciclistas casuais em todos os meses. Também se observa uma quantidade maior de passeios para ambos durante os meses de abril a novembro e uma quantidade menor nos meses de dezembro a março, que correspondem ao inverno no hemisfério norte.

Criando um gráfico da quantidade dos passeios por hora do dia para cada tipo de ciclista:

```
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, hour_of_day) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, hour_of_day)  %>% 
  ggplot(aes(x = hour_of_day, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge") +
  labs(title="Quantidade de passeios por hora do dia para cada tipo de ciclista",x="Hora do dia",y="Duração Média", fill= "Membro ou Casual")
```

![alternate text](./Rplot4.jpg "Title")

No gráfico acima, podemos observar que há uma quantidade de passeios maior entre aproximadamente as 4 horas da manhã e as 20 horas da noite para ambos os tipos de ciclistas. Também se observa que há uma quantidade um pouco maior de passeios para os ciclistas membros.


#### Conclusão Prévia 


Podemos perceber ao visualizar os gráficos que os ciclistas membros e ciclistas casuais se comportam de maneira diferente, pois:

A quantidade de passeios para usuários membros para cada hora do dia, durante a semana e em cada mês do ano é geralmente maior comparada a quantidade de passeios para usuários casuais.

A duração dos passeios para usuários casuais durante a semana é no geral maior do que para usuários membros.

Ambos os usuários tem uma quantidade de passeios menor durante os meses de inverno no hemisfério norte.

Ambos os usuários tem uma quantidade de passeios menor durante a noite.
