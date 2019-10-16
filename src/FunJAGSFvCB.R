FunJAGSFvCBgm <- function(IPT.Ci, IPT.Q, IPT.A, IPT.yii, PPFDdetected, JAGS.fixedpar, JAGS.ini) {
    # Bayesian estimation with JAGS (Just another Gibbs sampler)
    # for Farquhar-von Caemmerer-Berry model (FvCB) with gm
    #
    # Yi Xiao (xiaoyi@sippe.ac.cn)
    # 2019/6/20
    #
    # Args:
    # IPT.Ci:  input obs Ci;  vector;
    # IPT.Q:   input obs Q ;  vector; light levels controlled
    # IPT.A:   input obs A ;  vector; corresponding to IPT.Ci
    # IPT.yii: input obs yii; vector; corresponding to IPT.Ci
    # PPFDdetected: light levels, to keep a consistent J[n] among JAGS with different replications
    # JAGS.fixedpar: configure prefixed parameters during estimation
    # JAGS.ini: configure n.chain, n.burnin, n.iter and n.thin for JAGS
    #
    # Returns:
    # jagsfit.p from jags.parallel()
    
    require(coda)
    require(R2jags)

    # model.file <- system.file(package="R2jags", "model", "fvcb_ayii_ciLL_gm_fixKm.txt")
    # file.show(model.file) # show model

    PPFDidx <- vector()
    for (tmploop in seq_along(PPFDdetected)) {
        PPFDidx[IPT.Q==PPFDdetected[tmploop]] <- tmploop
    }
    Ci <- IPT.Ci
    Aobs <- IPT.A
    yiiobs <- IPT.yii
    numPts <- length(IPT.A)
    PPFD <- PPFDdetected
    numPPFD <- length(PPFDdetected)
    # Km <- 535.3270
    for (loop in seq_along(JAGS.fixedpar)) {
        assign(names(JAGS.fixedpar)[loop], JAGS.fixedpar[[loop]])
    }
    
    jags.data <- list("Ci", "Aobs", "yiiobs", "numPts", 
                      "PPFD", "PPFDidx", "numPPFD",
                      "Km")
    jags.params <- c("Vcmax", "J", "Resp", "Km", "Gstar", "rm",
                     "s", "taoA", "taoyii")
    #inits is a list with n.chains elements or a function
    jags.inits <- function(){
        list("sigA" = 2, 
             "sigyii" = 0.2,
             "Vcmax" = 100,
             "J" = seq(125, by = 0, length.out = numPPFD),
             "Resp" = 2,
             "Gstar" = 30,
             "rm" = 1,
             "s" = 0.85*0.5)
    }
    
    for (loop in seq_along(JAGS.ini)) {
        assign(names(JAGS.ini)[loop], JAGS.ini[[loop]])
    }
    
    #===============================#
    # RUN jags and postprocessing   #
    #===============================#
    #jagsfit.p <- jags.parallel(data = jags.data, inits = jags.inits, jags.params,
    #                           model.file="./src/fvcb_ayii_ciLL_gm_fixKm_vR.txt",
    #                           n.chains = 3, n.burnin = 10000, n.iter = 20000, n.thin = 1, 
    #                           DIC = TRUE, working.directory = NULL, jags.seed = 123)
    jagsfit.p <- jags.parallel(data = jags.data, inits = jags.inits, jags.params,
                               model.file="./src/fvcb_ayii_ciLL_gm_fixKm_vR.txt",
                               n.chains = CFG.nchain, n.burnin = CFG.nburnin, n.iter = CFG.niter, n.thin = CFG.nthin, 
                               DIC = TRUE, working.directory = NULL, jags.seed = 123)
}

FunFvCBgmOPTAYII2ci <- function(ARG.ci, ARG.vm, ARG.km, ARG.gstar, ARG.resp, 
                           ARG.rm, ARG.ppfd, ARG.j, ARG.s) {
    # function of Farquhar-von Caemmerer-Berry model (FvCB), with gm;
    # input is JAGS results with a single J (multiple J is not supported)
    # "OPTAYII2ci" = output is response curve of An and Y(II) to Ci
    #
    # Yi Xiao (xiaoyi@sippe.ac.cn)
    # 2019/6/11
    #
    # Args:
    #   ci: vector of Ci levels
    #   vm: value of Vcmax
    #   km: value of Km
    #   gstar: value of gamma star
    #   resp: value of respiration rate under light
    #   rm: value of mesophyll resistance (unit: ubar/(umol m-2 s-1))
    #   ppfd: value/vector of incident irradiance (umol photons m-2 s-1)
    #       if ppfd is a vector, it must be the same length as ci
    #   jm: value of Jmax
    #   theta: curvature index of J-Q curve
    #   abs: light absorption
    #   s: lumped parameter of light absorption and partition coefficienct of absorbed photon to PSII
    #       i.e. J=PPFD*abs*beta*Y(II)=PPFD*s*Y(II) (Yin et al., 2004)
    #            
    # Returns:
    #   OPTList$A:   net photosynthesis rate
    #   OPTList$yii: Y(II)
    #   #OPTList$cc:  chloroplastic [CO2]
    #   #OPTList$Ac:  Rubisco-limited A
    #   #OPTList$Aj:  RuBP regeneration-limited A
    #
    # Example:
    # ci <- c(seq.int(30, 300, 20), seq.int(400, 1300, 50))
    # vm <- 72.5152
    # km <- 535.3270
    # gstar <- 38.5143
    # resp <- 3.32
    # rm <- 5
    # ppfd <- 1500
    # j <- 167.1765
    # theta <- 0.7
    # s <- 0.85*0.425
    # test <- FunFvCBgmOPTAYII2ci(ci, vm, km, gstar, resp,
    #                             rm, ppfd, j, s)
    
    ARG.gm <- 1 / ARG.rm
    ## A^2 - A * (gm * (ci + km) + vm - rd) + gm * (vm * (ci - gamma) - rd * (km + ci)) = 0
    eqna <- 1
    eqnb <- -(ARG.gm * (ARG.ci + ARG.km) + ARG.vm - ARG.resp)
    eqnc <- ARG.gm * (ARG.vm * (ARG.ci - ARG.gstar) - ARG.resp * (ARG.km + ARG.ci))
    Ac <- 1 / (2 * eqna) * (-eqnb - sqrt(eqnb^2 - 4 * eqna * eqnc))
    ## A^2 - A * (gm *(ci + 2 * gamma) + j/4 - rd) + gm * (j/4 * (ci - gamma) - rd * (2 * gamma + ci)) = 0
    eqna <- 1
    eqnb <- -(ARG.gm * (ARG.ci + 2 * ARG.gstar) + ARG.j/4 - ARG.resp)
    eqnc <- ARG.gm * (ARG.j/4 * (ARG.ci - ARG.gstar) - ARG.resp * (2 * ARG.gstar + ARG.ci))
    Aj <- 1 / (2 * eqna) * (-eqnb - sqrt(eqnb^2 - 4 * eqna * eqnc))
    ## direct min(Ac , Aj) here is wrong
    A <- pmin(Ac , Aj)
    idx <- which(A < (-ARG.resp))
    if (length(idx) != 0){
        A[idx] <- pmax(Ac[idx],Aj[idx])
    }
    
    cc <- ARG.ci - A/ARG.gm
    jreal <- pmin(ARG.vm * (4 * cc + 8 * ARG.gstar) / (cc + ARG.km) , ARG.j)
    yii <- jreal / (ARG.ppfd * ARG.s)
    
    #return list
    OPTList <- list("A" = A, "yii" = yii)
}