/**
 * Lead form handler for Escriturashoy public site
 */

// API endpoint - adjust for staging/production
const API_BASE_URL = import.meta.env.VITE_API_URL || 'https://api-staging.escriturashoy.com';

/**
 * Show error message for a field
 */
function showFieldError(fieldId, message) {
  const field = document.getElementById(fieldId);
  const errorElement = document.getElementById(`${fieldId}-error`);

  if (field) {
    field.classList.add('error');
  }

  if (errorElement) {
    errorElement.textContent = message;
    errorElement.style.display = 'block';
  }
}

/**
 * Clear error message for a field
 */
function clearFieldError(fieldId) {
  const field = document.getElementById(fieldId);
  const errorElement = document.getElementById(`${fieldId}-error`);

  if (field) {
    field.classList.remove('error');
  }

  if (errorElement) {
    errorElement.textContent = '';
    errorElement.style.display = 'none';
  }
}

/**
 * Show form message (success or error)
 */
function showFormMessage(message, type = 'error') {
  const messageEl = document.getElementById('form-message');
  if (!messageEl) return;

  messageEl.textContent = message;
  messageEl.className = `form-message ${type}`;
  messageEl.style.display = 'block';

  // Scroll to message
  messageEl.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

/**
 * Clear form message
 */
function clearFormMessage() {
  const messageEl = document.getElementById('form-message');
  if (messageEl) {
    messageEl.textContent = '';
    messageEl.style.display = 'none';
    messageEl.className = 'form-message';
  }
}

/**
 * Validate form fields
 */
function validateForm(formData) {
  let isValid = true;

  // Clear all errors
  ['name', 'email', 'phone', 'property_location', 'property_type', 'urgency', 'privacy_consent', 'legal_disclaimer'].forEach(fieldId => {
    clearFieldError(fieldId);
  });

  // Validate name
  if (!formData.get('name') || formData.get('name').trim().length < 2) {
    showFieldError('name', 'El nombre debe tener al menos 2 caracteres');
    isValid = false;
  }

  // Validate email
  const email = formData.get('email');
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!email || !emailRegex.test(email)) {
    showFieldError('email', 'Ingresa un correo electrónico válido');
    isValid = false;
  }

  // Validate property_location
  if (!formData.get('property_location') || formData.get('property_location').trim().length < 3) {
    showFieldError('property_location', 'Ingresa la ubicación de la propiedad');
    isValid = false;
  }

  // Validate property_type
  const validPropertyTypes = ['casa', 'departamento', 'terreno', 'comercial'];
  const propertyType = formData.get('property_type');
  if (!propertyType || !validPropertyTypes.includes(propertyType)) {
    showFieldError('property_type', 'Selecciona un tipo de propiedad válido');
    isValid = false;
  }

  // Validate urgency if provided
  const urgency = formData.get('urgency');
  if (urgency) {
    const validUrgency = ['alta', 'media', 'baja'];
    if (!validUrgency.includes(urgency)) {
      showFieldError('urgency', 'Selecciona un nivel de urgencia válido');
      isValid = false;
    }
  }

  // Validate privacy consent
  if (!formData.get('privacy_consent')) {
    showFieldError('privacy_consent', 'Debes aceptar la Política de Privacidad');
    isValid = false;
  }

  // Validate legal disclaimer
  if (!formData.get('legal_disclaimer')) {
    showFieldError('legal_disclaimer', 'Debes aceptar el aviso legal');
    isValid = false;
  }

  return isValid;
}

/**
 * Handle form submission
 */
async function handleSubmit(event) {
  event.preventDefault();

  const form = event.target;
  const formData = new FormData(form);
  const submitButton = document.getElementById('submit-button');
  const buttonText = submitButton?.querySelector('.button-text');
  const buttonLoading = submitButton?.querySelector('.button-loading');

  // Clear previous messages
  clearFormMessage();

  // Validate form
  if (!validateForm(formData)) {
    showFormMessage('Por favor, corrige los errores en el formulario', 'error');
    return;
  }

  // Disable submit button
  if (submitButton) {
    submitButton.disabled = true;
  }
  if (buttonText) {
    buttonText.style.display = 'none';
  }
  if (buttonLoading) {
    buttonLoading.style.display = 'inline';
  }

  try {
    // Prepare request body
    const body = {
      name: formData.get('name').trim(),
      email: formData.get('email').trim(),
      property_location: formData.get('property_location').trim(),
      property_type: formData.get('property_type'),
    };

    // Add optional fields
    const phone = formData.get('phone')?.trim();
    if (phone) {
      body.phone = phone;
    }

    const urgency = formData.get('urgency');
    if (urgency) {
      body.urgency = urgency;
    }

    // Send request
    const response = await fetch(`${API_BASE_URL}/leads`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    });

    const data = await response.json();

    if (!response.ok) {
      // Handle API errors
      const errorMessage = data.message || data.error || 'Error al enviar la solicitud. Por favor, intenta nuevamente.';
      showFormMessage(errorMessage, 'error');

      // Show field-specific errors if available
      if (data.errors) {
        Object.keys(data.errors).forEach(field => {
          showFieldError(field, data.errors[field]);
        });
      }

      return;
    }

    // Success
    showFormMessage('¡Gracias! Hemos recibido tu solicitud. Nos pondremos en contacto contigo pronto.', 'success');
    form.reset();

    // Scroll to success message
    setTimeout(() => {
      document.getElementById('form-message')?.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }, 100);

  } catch (error) {
    console.error('Form submission error:', error);
    showFormMessage('Error de conexión. Por favor, verifica tu conexión a internet e intenta nuevamente.', 'error');
  } finally {
    // Re-enable submit button
    if (submitButton) {
      submitButton.disabled = false;
    }
    if (buttonText) {
      buttonText.style.display = 'inline';
    }
    if (buttonLoading) {
      buttonLoading.style.display = 'none';
    }
  }
}

/**
 * Initialize form handler
 */
document.addEventListener('DOMContentLoaded', () => {
  const form = document.getElementById('lead-form');
  if (form) {
    form.addEventListener('submit', handleSubmit);

    // Clear errors on input
    form.addEventListener('input', (e) => {
      if (e.target.tagName === 'INPUT' || e.target.tagName === 'SELECT') {
        clearFieldError(e.target.id);
        clearFormMessage();
      }
    });

    // Clear errors on change (for checkboxes)
    form.addEventListener('change', (e) => {
      if (e.target.type === 'checkbox') {
        clearFieldError(e.target.id);
        clearFormMessage();
      }
    });
  }

  // Smooth scroll for anchor links
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
      const href = this.getAttribute('href');
      if (href === '#') return;

      e.preventDefault();
      const target = document.querySelector(href);
      if (target) {
        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
    });
  });
});

