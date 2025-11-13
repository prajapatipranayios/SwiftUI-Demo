//
//  ViewController.swift
//  ProgrssBars
//
//  Created by Marina on 09/05/2020.
//  Copyright © 2020 Marina. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var horizontalBar: PlainHorizontalProgressBar!
    @IBOutlet weak var gradientHorizontalBar: GradientHorizontalProgressBar!
    @IBOutlet weak var ringBar: PlainCircularProgressBar!
    @IBOutlet weak var gradientCircularProgressBar: GradientCircularProgressBar!
    @IBOutlet weak var rotatingProgressBar: RotatingCircularGradientProgressBar!

    @IBOutlet weak var redColorSlider: UISlider!
    @IBOutlet weak var greenColorSlider: UISlider!
    @IBOutlet weak var blueColorSlider: UISlider!

    @IBOutlet weak var redGradientSlider: UISlider!
    @IBOutlet weak var greenGradientSlider: UISlider!
    @IBOutlet weak var blueGradientSlider: UISlider!

    @IBOutlet weak var progressSlider: UISlider!

    var colorRed: CGFloat = 250
    var colorGreen: CGFloat = 186
    var colorBlue: CGFloat = 218

    var gradientRed: CGFloat = 255
    var gradientGreen: CGFloat = 255
    var gradientBlue: CGFloat = 255

    @IBAction func progressChanged(_ sender: UISlider) {
        let progress = CGFloat(sender.value)
        horizontalBar.progress = progress
        gradientHorizontalBar.progress = progress
        ringBar.progress = progress
        gradientCircularProgressBar.progress = progress
        rotatingProgressBar.progress = progress
    }


    // MARK: ColorSliders

    @IBAction func colorChanged(_ sender: UISlider) {
        let value = CGFloat(sender.value)
        switch sender {
            case redColorSlider:
                colorRed = value
            case greenColorSlider:
                colorGreen = value
            case blueColorSlider:
                colorBlue = value
            case redGradientSlider:
                gradientRed = value
            case greenGradientSlider:
                gradientGreen = value
            case blueGradientSlider:
                gradientBlue = value
            default:
                preconditionFailure("invalid slider")
        }
        updateColors()
    }

    private func updateColors() {
        let mainColor = UIColor(red: colorRed / 255, green: colorGreen / 255, blue: colorBlue / 255, alpha: 1)
        let gradient = UIColor(red: gradientRed / 255, green: gradientGreen / 255, blue: gradientBlue / 255, alpha: 1)

        horizontalBar.color = mainColor
        gradientHorizontalBar.color = mainColor
        ringBar.color = mainColor
        gradientCircularProgressBar.color = mainColor
        rotatingProgressBar.color = mainColor

        gradientHorizontalBar.gradientColor = gradient
        gradientCircularProgressBar.gradientColor = gradient
        rotatingProgressBar.gradientColor = gradient

        progressSlider.tintColor = mainColor
    }
}

