import React, { useState } from 'react';

const headline = "Empower Your Fitness Journey with NoFF: Connect, Inspire, and Thrive Together"
const message = `Discover a vibrant community where everyone comes together to share innovative workout ideas and motivational stories. At NoFF, we believe that a healthy lifestyle is a shared journey.
Join us to connect with like-minded individuals, find your fitness tribe, and inspire each other to reach new heights.
Together, we turn goals into achievements and dreams into realities.
Share your progress, celebrate your victories, and become part of a supportive network that's dedicated to living well and staying active. Your path to wellness starts here.`;

export const leftSide = () => { 
  return ( 
    <div> 
      <h1> {headline} </h1>
      <p> {message} </p>
    </div>
  )
}