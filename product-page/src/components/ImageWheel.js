import React from 'react'
import dog from '../assets/pizza_dog_0.png';
import diane from '../assets/test.jpg';
import avatar from '../assets/avi.png'
import { Carousel } from 'react-responsive-carousel' 

import Slider from 'react-slick';
import 'slick-carousel/slick/slick.css';
import 'slick-carousel/slick/slick-theme.css';


const items = [
    {
      image: dog,
      alt: 'Image 1',
      title: 'Title 1',
      description: 'This is the description for image 1.'
    },
    {
      image: diane,
      alt: 'Image 2',
      title: 'Title 2',
      description: 'This is the description for image 2.'
    },
    {
      image: avatar,
      alt: 'Image 3',
      title: 'Title 3',
      description: 'This is the description for image 3.'
    }
  ];

const settings = {
    dots: true,
    infinite: true,
    speed: 500,
    slidesToShow: 3,
    slidesToScroll: 1,
    centerMode: true,
    centerPadding: '0',
    focusOnSelect: true,
    responsive: [
      {
        breakpoint: 1024,
        settings: {
          slidesToShow: 3,
          slidesToScroll: 1,
        },
      },
      {
        breakpoint: 600,
        settings: {
          slidesToShow: 1,
          slidesToScroll: 1,
        },
      },
    ],
  };

export const ImageWheel = () => { 
    return (
    <Slider {...settings}>
      {items.map((item, index) => (
        <div key={index} className="carousel-item">
          <img src={item.image} alt={item.alt} className="carousel-image" />
          <div className="carousel-description">
            <h3>{item.title}</h3>
            <p>{item.description}</p>
          </div>
        </div>
      ))}
    </Slider>
    ); 
}