import React, { useState } from 'react';
import giftGenerateStart from "../../images/gift-generate.png";
import giftCard from "../../images/gift-g1.jpeg";

const GiftGenerator = () => {
  const [currentStep, setCurrentStep] = useState(1);
  const [formData, setFormData] = useState({
    group_name: '',
    event_date: '',
    budget: '',
    message: '',
    user_attributes: {
      email: '',  
      name: ''
    },
    participants_attributes: [
      { user_attributes: { email: '' } }
    ]
  });

  const handleNextStep = () => {
    setCurrentStep(prev => prev + 1);
  };

  const handlePreviousStep = () => {
    setCurrentStep(prev => prev - 1);
  };

  const handleInputChange = (e, index = null) => {
    const { name, value } = e.target;
  
    if (name === 'participants' && index !== null) {
      const updatedParticipants = [...formData.participants_attributes];
      updatedParticipants[index] = { 
        user_attributes: { ...updatedParticipants[index].user_attributes, email: value } 
      };
      setFormData(prev => ({ ...prev, participants_attributes: updatedParticipants }));

    } else if (name ==='email' || name ==='name'){
        setFormData(prev => ({ 
        ...prev, 
        user_attributes: { ...prev.user_attributes, [name]: value } 
      }));
    } else {
      setFormData(prev => ({ ...prev, [name]: value }));
    }
  };

  const addParticipant = () => {
    setFormData(prev => ({
      ...prev,
      participants_attributes: [...prev.participants_attributes, { user_attributes: { email: '' } }]
    }));
  };
  
  const handleStepChange = (e) => {
    if (currentStep === 7) {
      handleSubmit(e);
    } else {
      handleNextStep(); 
    }
  };

  const handleSubmit = async (e = null) => {
    if (e) e.preventDefault();
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
    console.log('Form submitted:', formData);
    try {
      const response = await fetch('/groups', { 
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken
        },
        body: JSON.stringify({ group: formData }),
      });
  
      const data = await response.json();
  
      if (response.ok) {
        console.log('Group created successfully:', data.message);
      } else {
        console.error('Error creating group:', data.errors);
        alert('Error: ' + data.errors.join(', '));
      }
    } catch (error) {
      console.error('Submission error:', error);
    }
  };  

  return (
    <div className="row">
      <div className="content">
        <div className="introduction">
          <h1>Gift Generator</h1>
          <p>Organize your Secret Santa using Email or Text Message.</p>
          <div className="gift-image-card">
            <img src={giftCard} alt="Name" />
          </div>
        </div>

        <div className="card">
          <fieldset className="canremove">
            {currentStep === 1 && (
              <>
                <label htmlFor="organisername">What's your Name?</label>
                <div className="container-flex">
                  <input
                    type="text"
                    name="name"
                    id="organisername"
                    maxLength="32"
                    autoCorrect="off"
                    autoCapitalize="sentences"
                    spellCheck="false"
                    placeholder="Fill in your name..."
                    value={formData.user_attributes.name}
                    onChange={handleInputChange}
                  />
                  <div className="remove"></div>
                </div>
              </>
            )}

            {currentStep === 2 && (
              <>
                <label>Participants' Names:</label>
                {formData.participants_attributes.map((participant, index) => (
                  <div className="container-flex" key={index}>
                    <input
                      type="email"
                      name="participants"
                      placeholder={`Participant ${index + 1}`}
                      value={participant.user_attributes?.email || ''}
                      onChange={(e) => handleInputChange(e, index)}
                    />
                    {index === formData.participants_attributes.length - 1 && (
                      <button type="button" onClick={addParticipant}>+</button>
                    )}
                  </div>
                ))}
              </>
            )}

            {currentStep === 3 && (
              <>
                <label htmlFor="group_name">What do you want to draw names for?</label>
                <div className="container-flex">
                  <input
                    type="text"
                    name="group_name"
                    id="group_name"
                    maxLength="32"
                    autoCorrect="off"
                    autoCapitalize="sentences"
                    spellCheck="false"
                    placeholder="Enter a Group Name..."
                    value={formData.group_name}
                    onChange={handleInputChange}
                  />
                  <div className="remove"></div>
                </div>
              </>
            )}

            {currentStep === 4 && (
              <>
                <label htmlFor="date">When are you going to celebrate?</label>
                <div className="container-flex">
                  <input
                    type="date"
                    name="event_date"
                    id="event_date"
                    maxLength="32"
                    autoCorrect="off"
                    autoCapitalize="sentences"
                    spellCheck="false"
                    placeholder="Select Date..."
                    value={formData.event_date}
                    onChange={handleInputChange}
                  />
                  <div className="remove"></div>
                </div>
              </>
            )}

            {currentStep === 5 && (
              <>
                <label htmlFor="budget">How much should people spend?</label>
                <div className="container-flex">
                  <input
                    type="text"
                    name="budget"
                    id="budget"
                    maxLength="32"
                    autoCorrect="off"
                    autoCapitalize="sentences"
                    spellCheck="false"
                    placeholder="Enter a gift budget"
                    value={formData.budget}
                    onChange={handleInputChange}
                  />
                  <div className="remove"></div>
                </div>
              </>
            )}

            {currentStep === 6 && (
              <>
                <label htmlFor="message">What is your message for group members?</label>
                <div className="container-flex">
                  <input
                    type="text"
                    name="message"
                    id="message"
                    maxLength="32"
                    autoCorrect="off"
                    autoCapitalize="sentences"
                    spellCheck="false"
                    placeholder="Enter Messages for your Group..."
                    value={formData.message}
                    onChange={handleInputChange}
                  />
                  <div className="remove"></div>
                </div>
              </>
            )}

            {currentStep === 7 && (
              <>
                <label htmlFor="message">What is your email address?</label>
                <div className="container-flex">
                  <input
                    type="email"
                    name="email"
                    id="email"
                    maxLength="32"
                    autoCorrect="off"
                    autoCapitalize="sentences"
                    spellCheck="false"
                    placeholder="Find in your email address..."
                    value={formData.user_attributes.email}
                    onChange={handleInputChange}
                  />
                  <div className="remove"></div>
                </div>
              </>
            )}

            {currentStep > 1 && (
              <input
                type="button"
                value="< Previous"
                className="continue"
                onClick={handlePreviousStep} 
              />
            )}
  
            <input
              type="button"
              value={currentStep === 7 ? "Submit" : "Next >"}
              className="continue"
              onClick={(e) => handleStepChange(e)} 
            />
          </fieldset>

          <div className="line"></div>
        </div>

        <div className="container-introduction">
          <h3>Did you draw names last year?</h3>
          <p>
            Use your <a href="/retrieve-last-year">group from 2024</a> so that no one draws the same name as last year's gift exchange.
          </p>
        </div>
      </div>

      <div className="gift-image">
        <img src={giftGenerateStart} alt="Gift Generator" />
      </div>
    </div>
  );
};  

export default GiftGenerator;
