import React from "react";
import { Navbar, Nav, NavDropdown, Container } from "react-bootstrap";
import { FaUser, FaGift, FaSignInAlt, FaSignOutAlt, FaList } from "react-icons/fa"; // Import icons

const Header = () => {

  const handleLogout = async () => {
    const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
    try {
      const response = await fetch("/users/sign_out", {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken,
        },
      });
      if (response.ok) {
        window.location.href = "/";
      } else {
        console.error("Log out failed.");
      }
    } catch (error) {
      console.error("An error occurred during logout:", error);
    }
  };

  return (
    <Navbar expand="lg" className="navbar-custom shadow-sm fixed-top">
      <Container>
        <Navbar.Brand href="/" className="fw-bold fs-4">
          🎁 SurpriSeasy
        </Navbar.Brand>

        <Navbar.Toggle aria-controls="basic-navbar-nav" />
        <Navbar.Collapse id="basic-navbar-nav">
          <Nav className="ms-auto">
            <Nav.Link href="/" className="nav-link-custom">Home</Nav.Link>
            <Nav.Link href="/about" className="nav-link-custom">About</Nav.Link>

            <NavDropdown title="Services" id="basic-nav-dropdown" className="nav-dropdown-custom">
              <NavDropdown.Item href="/gift-generator"><FaGift className="me-2" /> Start Drawing Name</NavDropdown.Item>
              <NavDropdown.Item href="/items"><FaList className="me-2" /> My Wishlist</NavDropdown.Item>
              <NavDropdown.Item href="/groups"><FaGift className="me-2" /> My Group Page</NavDropdown.Item>
              <NavDropdown.Item href="/services/drawn-name"><FaGift className="me-2" /> My Drawn Name</NavDropdown.Item>
              <NavDropdown.Divider />
              <NavDropdown.Item href="/users/sign_in"><FaSignInAlt className="me-2" /> Sign In</NavDropdown.Item>
              <NavDropdown.Item as="button" onClick={handleLogout}><FaSignOutAlt className="me-2 text-danger" /> Sign Out</NavDropdown.Item>
            </NavDropdown>

            <Nav.Link href="/profile" className="nav-link-custom">
              <FaUser className="me-2" /> Profile
            </Nav.Link>
          </Nav>
        </Navbar.Collapse>
      </Container>
    </Navbar>
  );
};

export default Header;
