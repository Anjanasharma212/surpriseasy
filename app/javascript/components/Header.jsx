import React from "react";
import { Navbar, Nav, NavDropdown, Container } from "react-bootstrap";
import './Header.css';

const Header = () => {
  return (
    <Navbar expand="lg" className="navbar-custom">
      <Container>
        
        <Navbar.Brand href="/">SurpriSeasy</Navbar.Brand>
        <Navbar.Toggle aria-controls="basic-navbar-nav" />

        <Navbar.Collapse id="basic-navbar-nav">
          <Nav className="ms-auto">
            <Nav.Link href="/" className="nav-link-custom">Home</Nav.Link>
            <Nav.Link href="/about" className="nav-link-custom">About</Nav.Link>

            <NavDropdown title="Services" id="basic-nav-dropdown" className="nav-dropdown-custom">
              <NavDropdown.Item href="/services/wishlists">My Wishlist</NavDropdown.Item>
              <NavDropdown.Item href="/services/group-page">My Group Page</NavDropdown.Item>
              <NavDropdown.Item href="/services/drawn-name">My Drawn Name</NavDropdown.Item>
              <NavDropdown.Item href="/services/sign-in-status">Sign in </NavDropdown.Item>
            </NavDropdown>

            <Nav.Link href="/profile" className="nav-link-custom">Profile</Nav.Link>
          </Nav>
        </Navbar.Collapse>
      </Container>
    </Navbar>
  );
};

export default Header;
