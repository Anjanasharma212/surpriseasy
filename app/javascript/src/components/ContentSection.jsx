import React from 'react';

const ContentSection = () => {
  return (
    <div className="content home">
      <h1>Draw names for your <b>SurprisEasy</b> gift exchange!</h1>
      <p className="gray">In 2024, almost <b>35 million</b> names have been drawn.</p>
      <p className="accent">
        drawnames<sup>®</sup> is the best free <a href="/secret-santa">Secret Santa</a> Generator online for Christmas and other festivities!
      </p>
      <ul>
        <li><a href="/secret-santa-generator">Secret Santa Generator</a> with wish lists</li>
        <li>Search personal gift ideas in our <a href="/gift-finder">Gift Finder</a></li>
        <li>Ask your Secret Santa anonymous questions</li>
      </ul>
      <div className="container-button">
        <a 
          className="button" 
          href={window.location.origin + '/gift-generator'} 
        >
          Start Drawing Names
        </a>
      </div>
    </div>
  );
};

export default ContentSection;
