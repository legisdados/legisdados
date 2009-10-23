recode.billtype <-
function(x) {
    car::recode(x,"'PLN'='PL';c('MP','MEDIDA')='MPV';c('MENSAGEM', 'MENS','MSG')='MSC';c('PARECER')='PAR';'PDL'='PDC';'PLC'='PLP';'PROCESSO'='PRC';'PROPOSICAO'='PRP';'RECURSO'='REC';'REQUERIMENTO'='REQ';'L'='PL'")
}

