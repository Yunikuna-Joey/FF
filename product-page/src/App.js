import React, { useEffect } from 'react'
import './App.css';
import { ImageWheel } from './components/ImageWheel'

function App() {
  useEffect(() => {
    document.title = 'NoFF'
  }, [])

  return (
    <div className="App">
      <ImageWheel />
    </div>
  );
}

export default App;
