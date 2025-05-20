import React from "react";
// import giftExchange from "../../images/home.png";
import { Container, Row, Col, Button, Card } from "react-bootstrap";

const Home = () => {
  return (
    <Container className="d-flex justify-content-center align-items-center min-vh-100">
      <Row className="w-100">
        <Col md={6} className="d-flex flex-column justify-content-center">
          <h1 className="fw-bold text-primary">
            Draw names for your <span className="text-danger">SurprisEasy</span> gift exchange!
          </h1>
          <p className="text-muted fs-5">
            In 2024, almost <b>5 million</b> names have been drawn.
          </p>
          <p className="text-secondary">
            drawnames<sup>®</sup> is the best free 
            <a href="/secret-santa" className="text-decoration-none text-danger">
              Secret Santa
            </a> Generator online for Christmas and other festivities!
          </p>
          <ul className="list-unstyled">
            <li>🎁 <a href="/secret-santa-generator" className="text-dark fw-bold">Group Generator</a> with wish lists</li>
            <li>🔍 Search personal gift ideas in our <a href="/gift-finder" className="text-dark fw-bold">Gift Finder</a></li>
            <li>❓ Ask your Secret Santa anonymous questions</li>
          </ul>
          <Button href="/group_generator" variant="danger" className="mt-3 px-4 py-2">
            🎅 Start Drawing Names
          </Button>
        </Col>

        <Col md={6} className="d-flex justify-content-center">
          <Card className="border-0">
            {/* <Card.Img src={giftExchange} alt="Gift Exchange" className="rounded custom-img-size" /> */}
          </Card>
        </Col>
      </Row>
    </Container>
  );
};

export default Home;
