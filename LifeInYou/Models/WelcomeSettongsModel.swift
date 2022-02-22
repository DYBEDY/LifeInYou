//
//  WelcomeSettongsModel.swift
//  LifeInYou
//
//  Created by Roman on 22.02.2022.
//

import Foundation

struct LoginSteps {
    var steps: Steps
    
    static func takeAStep() -> [LoginSteps] {
        [LoginSteps(steps: Steps.step1),
         LoginSteps(steps: Steps.step2),
         LoginSteps(steps: Steps.step3),
         LoginSteps(steps: Steps.step4)
        ]
    }
}

enum Steps: String {
    case step1 = " Давай начнем со знакомства, как тебя зовут?"
    case step2 = "Расскажи нам, когда ты появился на свет? Это поможет быстрее посчитать количество прожитых тобой дней, так же не забудь выбрать пол"
    case step3 = "Введи свои почту и пароль, это необходио для сохранности твоих данных"
    case step4 = "fff"
}
