module Test.Main where

import Prelude

import Data.Array ((..))
import Data.Foldable (foldMap, fold)
import Data.Int (toNumber)

import Graphics.Isometric (Point, Color, cube, hsl, filled, rotateZ, scale,
                           renderScene, prism, gray)
import Graphics.Isometric.Point as P
import Graphics.Isometric.DepthSort (depthSort)

import Math (sin, cos, pi)

import Signal.DOM (animationFrame)

import Flare (numberSlider, lift, intSlider)
import Flare.Drawing as D

-- Example 1

scene1 :: Int -> Number -> D.Drawing
scene1 n offset =
  D.translate 250.0 150.0 $
    renderScene { x: -4.0, y: -1.0, z: 3.0 } $
      fold do
        i <- 0..n
        j <- 0..n
        let x = toNumber i / toNumber n
            y = toNumber j / toNumber n
            pos = { x: dl * toNumber i, y: dl * toNumber j, z: 0.0 }
            h = 2.0 * dl + 1.5 * dl * sin (pi * x + offset) * cos (pi * y + offset)
        return $ filled (D.hsl (300.0 * x) 0.5 0.5) (prism pos w w h)
  where dl = 230.0 / toNumber n
        w = 0.9 * dl

-- Example 2

red :: Color
red   = hsl 0.0 0.6 0.5

green :: Color
green = hsl 110.0 0.6 0.5

scene2 :: Number -> Number -> D.Drawing
scene2 rotZ time =
  D.translate 250.0 200.0 $
    renderScene { x: -4.0, y: -1.0, z: 3.0 } $
      scale 45.0 $ depthSort $ rotateZ rotZ $
           filled gray  (prism (P.point (-3.5) (-3.5) (-0.5)) 7.0 7.0 0.5)
        <> filled green (prism (P.point (-1.0) pos1 0.0) 2.0 1.0 2.0)
        <> filled red   (prism (P.point pos2 (-1.0) 0.0) 1.0 2.0 2.0)
  where
    pos1 = 3.0 * cos (0.001 * time) - 0.5
    pos2 = 3.0 * sin (0.001 * time) - 0.5

-- Example 3

p :: Int -> Int -> Int -> Point
p x y z = { x: toNumber x, y: toNumber y, z: toNumber z }

scene3 :: Number -> D.Drawing
scene3 angle =
  D.translate 300.0 150.0 $
    renderScene { x: -4.0, y: -1.0, z: 3.0 } $
      scale 45.0 $ rotateZ angle $
        foldMap (\pos -> filled (hsl 210.0 0.8 0.5) (cube pos 1.0))
          [ p 1 1 0 , p 1 2 0 , p 1 3 0 , p 2 3 0
          , p 3 3 0 , p 0 (-2) 0 , p 1 (-2) 0 , p 2 (-2) 0
          , p 3 (-2) 0 , p 3 (-1) 0 , p 4 (-1) 0 , p 5 (-1) 0
          , p 5 (-1) 0 , p 5 0 0 , p 4 2 0 , p 5 1 0
          , p 5 2 0 , p 4 3 0 , p 1 0 1 , p 1 1 1
          ]

main = do
  D.runFlareDrawing "controls1" "canvas1" $
    scene1 <$> intSlider "Points" 4 10 8
           <*> numberSlider "Wave" 0.0 (2.0 * pi) 0.01 0.0

  D.runFlareDrawing "controls2" "canvas2" $
    scene2 <$> numberSlider "Rotation" 0.0 (2.0 * pi) 0.1 0.0
           <*> lift animationFrame

  D.runFlareDrawing "controls3" "canvas3" $
    scene3 <$> numberSlider "Rotation" (-0.25 * pi) (0.25 * pi) 0.01 0.0